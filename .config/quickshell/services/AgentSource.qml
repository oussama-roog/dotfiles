import QtQuick
import Quickshell
import Quickshell.Io

/**
 * One coding agent's sessions and plan usage, read from the state file its
 * bridge keeps (~/dotfiles/scripts/<agent>-qs, run as the agent's hooks and
 * status line; see scripts/qs_agent.py for the shape). The file is watched, so
 * the dot and the agents surface update the moment a session starts working,
 * asks for a permission or finishes.
 *
 * Agents.qml declares one per agent; adding one (Codex, …) is a bridge that
 * writes the same file plus an entry there.
 *
 * Only open sessions are listed: the bridge drops a session once it ends or
 * its process exits. A session flagged `viewer` (a claude that only shows a
 * background job) is left out, so a job counts once. `sessions` is sorted:
 * sessions that need you first, then working ones, then idle and done,
 * newest first within each. Each carries `agent: key`, so Agents can route it.
 */
Scope {
    id: root

    /** Short id, also the bridge's cache folder: ~/.cache/qs-<key>/. */
    required property string key
    /** Name shown on the agents surface tab. */
    required property string label
    /** The bridge script (focus, forget, sweep). */
    required property string bridge
    /** The agent's own colour: its spinners and marks, whatever the theme. */
    property color color: "#888888"
    /** The agent's command, for the empty-list hint. */
    property string command: key
    /** Plan windows the bridge writes under `usage`, in display order: [{ key, label }]. */
    property var windows: []
    /** Said in place of the usage bars until a session reports them. */
    property string usageHint: "Shows up once a session reports its limits."

    /** Wall clock in ms; Agents ticks it for every source. */
    property double now: Date.now()

    readonly property string stateFile: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/qs-" + key + "/state.json"

    property var data: ({ sessions: {}, usage: {} })

    readonly property var rank: ({ waiting: 0, question: 0, working: 1, idle: 2, done: 3 })

    readonly property var sessions: {
        var map = data.sessions || {};
        var out = Object.keys(map).map(function(k) { return Object.assign({ agent: root.key }, map[k]); })
            .filter(function(s) { return !s.viewer; });
        out.sort(function(a, b) {
            var ra = root.rank[a.status] !== undefined ? root.rank[a.status] : 4;
            var rb = root.rank[b.status] !== undefined ? root.rank[b.status] : 4;
            return ra !== rb ? ra - rb : (b.updated || 0) - (a.updated || 0);
        });
        return out;
    }

    readonly property var attention: sessions.filter(function(s) { return s.status === "waiting" || s.status === "question"; })
    readonly property int working: sessions.filter(function(s) { return s.status === "working"; }).length
    readonly property int running: attention.length + working
    readonly property bool needsYou: attention.length > 0

    /** The session that most recently finished a turn, within the last few seconds. */
    readonly property var justDone: {
        var best = null;
        for (var i = 0; i < sessions.length; i++) {
            var s = sessions[i];
            if (s.status === "done" && now - (s.updated || 0) < 6000 && (!best || s.updated > best.updated))
                best = s;
        }
        return best;
    }

    readonly property var usage: data.usage || {}
    /** [{ label, pct, resetsAt }] for every window the bridge has reported. */
    readonly property var plan: {
        var out = [];
        for (var i = 0; i < windows.length; i++) {
            var w = windowOf(windows[i].key);
            if (w)
                out.push({ label: windows[i].label, pct: w.pct, resetsAt: w.resetsAt });
        }
        return out;
    }
    readonly property bool hasUsage: plan.length > 0

    /** {pct, resetsAt} for a plan window, or null when it is missing or already reset. */
    function windowOf(k) {
        var w = usage[k];
        if (!w || typeof w.used_percentage !== "number")
            return null;
        var resets = (w.resets_at || 0) * 1000;
        if (resets > 0 && resets < now)
            return { pct: 0, resetsAt: 0 };
        return { pct: Math.max(0, Math.min(100, w.used_percentage)), resetsAt: resets };
    }

    function focus(id) {
        Quickshell.execDetached([bridge, "focus", id]);
    }

    function forget(id) {
        Quickshell.execDetached([bridge, "forget", id]);
    }

    /** The session's title (generated or renamed), else its folder. */
    function title(s) {
        return s.title || s.name || "session";
    }

    /**
     * Where the session lives: its folder (when the title isn't already the
     * folder) and its tmux spot, e.g. "dotfiles · main:2.1 nvim". Sessions
     * outside tmux that would still read the same get a short id.
     */
    function place(s) {
        var parts = [];
        if (s.title && s.name)
            parts.push(s.name);
        if (s.where)
            parts.push(s.where);
        if (!s.where && twins(s))
            parts.push("#" + String(s.id).slice(0, 4));
        return parts.join("  ·  ");
    }

    function twins(s) {
        for (var i = 0; i < sessions.length; i++) {
            var o = sessions[i];
            if (o.id !== s.id && title(o) === title(s) && (o.name || "") === (s.name || ""))
                return true;
        }
        return false;
    }

    FileView {
        id: file
        path: root.stateFile
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                var d = JSON.parse(text());
                if (d && typeof d === "object")
                    root.data = d;
            } catch (e) {
                // Mid-write or malformed: keep the last good state.
            }
        }
    }

    /**
     * Catches what no hook reports: a turn stopped with Ctrl+C and sessions
     * that died without saying so. Quick while anything runs, so the spinner
     * stops within a few seconds of an interrupt.
     */
    Timer {
        interval: root.running > 0 ? 3000 : 20000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: Quickshell.execDetached([root.bridge, "sweep"])
    }

    /** The file may not exist on first start; poll until the first hook makes it. */
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: file.reload()
    }
}
