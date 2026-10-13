pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Claude Code sessions and plan usage, read from the state file that
 * ~/dotfiles/scripts/claude-qs keeps (it runs as Claude Code's hooks and status
 * line). The file is watched, so the dot and the agents surface update the
 * moment a session starts working, asks for a permission or finishes.
 *
 * Only open sessions are listed: the bridge drops a session once it ends or
 * its process exits. A claude that only shows a background job (`viewer`) is
 * left out, so a job counts once. `sessions` is sorted: sessions that need you first, then
 * working ones, then idle and done, newest first within each.
 */
Singleton {
    id: root

    readonly property string bridge: Quickshell.env("HOME") + "/dotfiles/scripts/claude-qs"
    readonly property string stateFile: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/qs-claude/state.json"

    property var data: ({ sessions: {}, usage: {} })

    /** Wall clock in ms, ticking so ages and reset countdowns stay live. */
    property double now: Date.now()

    readonly property var rank: ({ waiting: 0, question: 0, working: 1, idle: 2, done: 3 })

    readonly property var sessions: {
        var map = data.sessions || {};
        var out = Object.keys(map).map(function(k) { return map[k]; }).filter(function(s) { return !s.viewer; });
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
    readonly property var fiveHour: windowOf("five_hour")
    readonly property var sevenDay: windowOf("seven_day")
    readonly property bool hasUsage: fiveHour !== null || sevenDay !== null

    /** {pct, resetsAt} for a plan window, or null when it is missing or already reset. */
    function windowOf(key) {
        var w = usage[key];
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

    function tokens(n) {
        if (!n)
            return "0";
        if (n >= 1e6)
            return (n / 1e6).toFixed(1) + "M";
        if (n >= 1e3)
            return (n / 1e3).toFixed(n >= 1e5 ? 0 : 1) + "k";
        return String(n);
    }

    /** "45s", "12m", "3h 5m", "2d 4h" — for ages and countdowns. */
    function span(ms) {
        var s = Math.max(0, Math.round(ms / 1000));
        if (s < 60)
            return s + "s";
        var m = Math.floor(s / 60);
        if (m < 60)
            return m + "m";
        var h = Math.floor(m / 60);
        if (h < 24)
            return h + "h" + (m % 60 ? " " + (m % 60) + "m" : "");
        var d = Math.floor(h / 24);
        return d + "d" + (h % 24 ? " " + (h % 24) + "h" : "");
    }

    /** The session's title (generated or /rename), else its folder. */
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

    function statusLabel(s) {
        switch (s.status) {
        case "waiting": return "needs permission";
        case "question": return "has a question";
        case "working": return "working";
        case "idle": return "idle";
        case "done": return "done";
        }
        return s.status || "";
    }

    /** The one line under a session: what it is doing, or what it last said. */
    function detail(s) {
        if (s.status === "waiting" || s.status === "question" || s.status === "working")
            return s.action || s.prompt || "";
        if (s.status === "idle")
            return s.last || "waiting for your prompt";
        return s.last || s.prompt || s.action || "";
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

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }

    /**
     * Catches what no hook reports: a turn stopped with Ctrl+C (no Stop fires)
     * and sessions that died without a SessionEnd. Quick while anything runs,
     * so the spinner stops within a few seconds of an interrupt.
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
