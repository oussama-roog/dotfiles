"""
Shared plumbing for the quickshell agent bridges (claude-qs, agy-qs, …).

Every bridge folds what its agent tells it (hooks, status line) into one state
file that services/AgentSource.qml watches:

    ~/.cache/qs-<agent>/state.json
    {
      "sessions": { "<id>": { id, name, cwd, status, action, prompt, last, ... } },
      "usage":    { "<window>": {used_percentage, resets_at}, ..., "updated": ms }
    }

Statuses: idle, working, waiting (permission prompt), question, done.

This module holds what does not depend on the agent: the locked state file,
text trimming, tmux lookups, and focusing the terminal a session runs in.
"""

import fcntl
import json
import os
import subprocess
import time


def now_ms():
    return int(time.time() * 1000)


def cache_dir(agent):
    return os.path.join(os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache"), "qs-" + agent)


class State:
    """An agent's state file, held under an exclusive lock for a read-modify-write."""

    def __init__(self, directory):
        self.dir = directory
        self.path = os.path.join(directory, "state.json")

    def __enter__(self):
        os.makedirs(self.dir, exist_ok=True)
        self.lock = open(os.path.join(self.dir, ".lock"), "w")
        fcntl.flock(self.lock, fcntl.LOCK_EX)
        try:
            with open(self.path) as f:
                self.data = json.load(f)
        except (OSError, ValueError):
            self.data = {}
        self.data.setdefault("sessions", {})
        self.data.setdefault("usage", {})
        self.dirty = False
        return self

    def __exit__(self, *exc):
        if self.dirty:
            tmp = self.path + ".tmp"
            with open(tmp, "w") as f:
                json.dump(self.data, f, separators=(",", ":"))
            os.replace(tmp, self.path)
        fcntl.flock(self.lock, fcntl.LOCK_UN)
        self.lock.close()


def one_line(text, limit=140):
    """First non-empty line of `text`, stripped of Markdown markers, cut to `limit`."""
    lines = [l.strip() for l in (text or "").splitlines() if l.strip()]
    # A reply that opens with a heading reads better from its first sentence.
    if len(lines) > 1 and lines[0].startswith("#"):
        lines = lines[1:]
    for line in lines:
        line = line.lstrip("#>*- ").replace("**", "").replace("`", "")
        if line:
            return line if len(line) <= limit else line[: limit - 1] + "…"
    return ""


def run(argv):
    try:
        return subprocess.run(argv, capture_output=True, text=True, timeout=3).stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def parent_of(pid):
    with open(f"/proc/{pid}/stat") as f:
        return int(f.read().rsplit(")", 1)[1].split()[1])


def ancestors(pid):
    out = []
    for _ in range(32):
        out.append(pid)
        try:
            pid = parent_of(pid)
        except (OSError, ValueError, IndexError):
            break
        if pid <= 1:
            break
    return out


def agent_pid(comm_has):
    """Walks up from the hook to the agent's process (its comm contains `comm_has`); falls back to the parent."""
    pid = os.getppid()
    for _ in range(6):
        try:
            with open(f"/proc/{pid}/comm") as f:
                if comm_has in f.read():
                    return pid
            pid = parent_of(pid)
        except (OSError, ValueError, IndexError):
            break
        if pid <= 1:
            break
    return os.getppid()


def alive(pid, comm_has):
    """True while `pid` is still the agent's process (a recycled pid doesn't count)."""
    try:
        with open(f"/proc/{int(pid)}/comm") as f:
            return comm_has in f.read()
    except (OSError, ValueError, TypeError):
        return False


def tmux_where(pane):
    """'main:2.1 nvim' — tmux session, window and pane, plus the window's name."""
    out = run(["tmux", "display-message", "-p", "-t", pane,
               "#{session_name}:#{window_index}.#{pane_index}\t#{window_name}"]).strip()
    loc, _, name = out.partition("\t")
    return loc + (" " + name if name else "")


def note_tmux(s, refresh):
    """Records the tmux pane the hook runs in; `refresh` re-reads its place (it may have moved)."""
    pane = os.environ.get("TMUX_PANE")
    if pane:
        s["tmuxPane"] = pane
        if not s.get("where") or refresh:
            s["where"] = tmux_where(pane) or s.get("where", "")


def drop_superseded(sessions, sid, pid):
    """Removes the other sessions that `pid` ran before `sid`; True if any went."""
    old = [k for k, o in sessions.items() if k != sid and o.get("pid") == pid]
    for k in old:
        del sessions[k]
    return bool(old)


def forget(directory, sid):
    with State(directory) as st:
        if st.data["sessions"].pop(sid, None) is not None:
            st.dirty = True


def niri_windows():
    """{pid: window id} of every niri window, or None when niri can't be asked."""
    try:
        windows = json.loads(run(["niri", "msg", "-j", "windows"]) or "[]")
    except ValueError:
        return None
    return {w.get("pid"): w.get("id") for w in windows if w.get("pid")}


def focus_session(s, by_pid):
    """
    Focuses the niri window whose process is an ancestor of the session; True
    if one was found. Under tmux the agent process hangs off the tmux server,
    so the pane is selected first and the walk starts from a client showing
    that tmux session, or, when none is, from a client switched over to it.
    """
    start = s.get("pid")
    pane = s.get("tmuxPane")
    if pane:
        session = run(["tmux", "display-message", "-p", "-t", pane, "#{session_name}"]).strip()
        if session:
            run(["tmux", "select-window", "-t", pane])
            run(["tmux", "select-pane", "-t", pane])
            clients = [l.split(" ", 2) for l in run(
                ["tmux", "list-clients", "-F", "#{client_pid} #{client_session} #{client_name}"]).splitlines()]
            clients = [c for c in clients if len(c) == 3 and c[0].isdigit()]
            here = [c for c in clients if c[1] == session]
            if not here and clients:
                run(["tmux", "switch-client", "-c", clients[0][2], "-t", pane])
                here = clients[:1]
            if here:
                start = int(here[0][0])
    if not start:
        return False
    for pid in ancestors(int(start)):
        if pid in by_pid:
            run(["niri", "msg", "action", "focus-window", "--id", str(by_pid[pid])])
            return True
    return False
