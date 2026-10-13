pragma Singleton

import QtQuick
import Quickshell

/**
 * Every coding agent the agents dot and centre follow, one AgentSource each,
 * and what they add up to: the dot shows the most pressing thing across all
 * of them, the centre has a tab per agent.
 *
 * To follow another agent (Codex, …): write a bridge that keeps
 * ~/.cache/qs-<key>/state.json in the same shape (scripts/qs_agent.py has the
 * shared parts), wire it into the agent's hooks, and add an AgentSource below
 * and to `sources`.
 */
Singleton {
    id: root

    readonly property string scripts: Quickshell.env("HOME") + "/dotfiles/scripts/"

    /** Wall clock in ms, ticking so ages and reset countdowns stay live. */
    property double now: Date.now()

    AgentSource {
        id: claude
        key: "claude"
        label: "Claude"
        color: "#d97757"
        bridge: root.scripts + "claude-qs"
        now: root.now
        windows: [{ key: "five_hour", label: "5 hours" }, { key: "seven_day", label: "Weekly" }]
        usageHint: "Shows up once a Claude Code session reports its limits."
    }

    AgentSource {
        id: agy
        key: "agy"
        label: "Antigravity"
        color: "#4285f4"
        bridge: root.scripts + "agy-qs"
        now: root.now
        windows: [
            { key: "gemini_5h", label: "Gemini 5h" },
            { key: "gemini_week", label: "Gemini wk" },
            { key: "other_5h", label: "Others 5h" },
            { key: "other_week", label: "Others wk" }
        ]
        usageHint: "Shows up once an agy session draws its status line."
    }

    /** In tab order. */
    readonly property var sources: [claude, agy]

    function source(key) {
        for (var i = 0; i < sources.length; i++)
            if (sources[i].key === key)
                return sources[i];
        return sources[0];
    }

    function labelOf(s) {
        return source(s.agent).label;
    }

    /** Every session that waits on you, newest first. */
    readonly property var attention: {
        var out = [];
        for (var i = 0; i < sources.length; i++)
            out = out.concat(sources[i].attention);
        out.sort(function(a, b) { return (b.updated || 0) - (a.updated || 0); });
        return out;
    }
    /** The colours of the agents that are working right now, in tab order. */
    readonly property var workingColors: sources.filter(function(src) { return src.working > 0; })
        .map(function(src) { return src.color; })
    readonly property int working: sources.reduce(function(n, src) { return n + src.working; }, 0)
    readonly property int running: attention.length + working
    readonly property bool needsYou: attention.length > 0
    /** More than one agent has open sessions: name the agent where it matters. */
    readonly property bool mixed: sources.filter(function(src) { return src.sessions.length > 0; }).length > 1

    /** The session that most recently finished a turn, any agent. */
    readonly property var justDone: {
        var best = null;
        for (var i = 0; i < sources.length; i++) {
            var s = sources[i].justDone;
            if (s && (!best || s.updated > best.updated))
                best = s;
        }
        return best;
    }

    function focus(s) {
        source(s.agent).focus(s.id);
    }

    function forget(s) {
        source(s.agent).forget(s.id);
    }

    function title(s) {
        return source(s.agent).title(s);
    }

    function place(s) {
        return source(s.agent).place(s);
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

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
