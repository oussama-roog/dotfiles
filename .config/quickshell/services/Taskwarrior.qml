pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Taskwarrior, for the tasks centre (Mod+T) and the launcher's `+` mode.
 *
 * Nothing is watched: the list is read with one `task export` at startup,
 * when the centre opens (refresh()) and after every change made from here.
 * So a task started from a terminal shows (in the notch border too) the next
 * time the centre opens. Commands run
 * one at a time through a queue, so a burst of actions never races on the
 * database. Each runs through a tiny sh wrapper that prints the command's
 * stdout, then its exit code and stderr after \x1e separators, so one
 * collector sees all three in order.
 *
 * Due dates are dates: a task due today is due all day, and overdue only from
 * the next morning (Taskwarrior itself would call `due:today` overdue from
 * midnight).
 */
Singleton {
    id: root

    /** Pending tasks plus those completed in the last week, normalised (see parse()). */
    property var tasks: []
    property bool loaded: false
    /** Last failure (no taskrc yet, a bad modifier…), shown by the centre; "" when fine. */
    property string error: ""
    readonly property bool busy: proc.running

    readonly property var pending: tasks.filter(t => t.status === "pending")
    readonly property var done: tasks.filter(t => t.status === "completed")
        .sort((a, b) => b.end - a.end)
    /** A task is started: the notch wears an accent border. */
    readonly property bool working: pending.some(t => t.start !== null)

    /** Ticks every 30s so ages, active timers and "today" stay current. */
    property real now: Date.now()

    readonly property var rc: ["rc.confirmation=off", "rc.recurrence.confirmation=no", "rc.verbose=nothing"]
    readonly property string wrapper: '{ err=$(task "$@" 2>&1 1>&3 3>&-); c=$?; } 3>&1; printf "\\036%d\\036%s" "$c" "$err"'

    // ─── Dates ───────────────────────────────────────────────────────────────

    /** Taskwarrior's 20261013T230000Z → Date, or null. */
    function parseDate(s) {
        if (!s)
            return null;
        var m = /^(\d{4})(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)Z$/.exec(s);
        return m ? new Date(Date.UTC(+m[1], +m[2] - 1, +m[3], +m[4], +m[5], +m[6])) : null;
    }

    function midnight(d) {
        return new Date(d.getFullYear(), d.getMonth(), d.getDate());
    }

    /** Calendar days from today to `d`: 0 today, 1 tomorrow, -1 yesterday. */
    function dayDiff(d) {
        void root.now;
        return Math.round((midnight(d) - midnight(new Date(root.now))) / 86400000);
    }

    /** Short due label for a list row: "today", "tomorrow", "Fri", "17 Oct", "2d late". */
    function dueShort(d) {
        var n = dayDiff(d);
        if (n === 0) return "today";
        if (n === 1) return "tomorrow";
        if (n === -1) return "yesterday";
        if (n < 0) return (-n) + "d late";
        if (n < 7) return Qt.formatDate(d, "ddd");
        return Qt.formatDate(d, d.getFullYear() === new Date(root.now).getFullYear() ? "d MMM" : "d MMM yyyy");
    }

    /** Due label for the details pane: "Fri 17 Oct · in 4 days". */
    function dueLong(d) {
        var n = dayDiff(d);
        var rel = n === 0 ? "today" : n === 1 ? "tomorrow" : n === -1 ? "1 day overdue"
            : n < 0 ? (-n) + " days overdue" : "in " + n + " days";
        return Qt.formatDate(d, "ddd d MMM") + "  ·  " + rel;
    }

    /** "just now", "12m", "3h", "2d", "5w" ago. */
    function ago(d) {
        var m = Math.max(0, Math.floor((root.now - d) / 60000));
        if (m < 1) return "just now";
        if (m < 60) return m + "m ago";
        var h = Math.floor(m / 60);
        if (h < 24) return h + "h ago";
        var days = Math.floor(h / 24);
        return days < 14 ? days + "d ago" : Math.floor(days / 7) + "w ago";
    }

    /** Time on a started task: "4m", "1h 20m", "2d 3h". */
    function elapsed(d) {
        var m = Math.max(0, Math.floor((root.now - d) / 60000));
        if (m < 60) return m + "m";
        var h = Math.floor(m / 60);
        if (h < 24) return h + "h " + (m % 60) + "m";
        return Math.floor(h / 24) + "d " + (h % 24) + "h";
    }

    // ─── Reading ─────────────────────────────────────────────────────────────

    function parse(t) {
        return {
            uuid: t.uuid,
            title: t.description || "",
            status: t.status,
            project: t.project || "",
            tags: t.tags || [],
            priority: t.priority || "",
            urgency: t.urgency || 0,
            due: parseDate(t.due),
            entry: parseDate(t.entry),
            start: parseDate(t.start),
            end: parseDate(t.end),
            wait: parseDate(t.wait),
            recur: t.recur || "",
            notes: (t.annotations || []).map(a => ({ entry: parseDate(a.entry), text: a.description }))
        };
    }

    /** Pending by urgency, then due date, then age. Waiting tasks stay hidden, as in `task list`. */
    function order(list) {
        var t = Date.now();
        return list.filter(x => x.status !== "pending" || !x.wait || x.wait <= t)
            .sort((a, b) => (b.urgency - a.urgency)
                || ((a.due ? a.due.getTime() : Infinity) - (b.due ? b.due.getTime() : Infinity))
                || (a.entry - b.entry));
    }

    function refresh() {
        run(["rc.json.array=on", "(", "status:pending", "or", "(", "status:completed", "end.after:today-7d", ")", ")", "export"],
            function(code, out, err) {
                if (code !== 0) {
                    root.error = err || "task exited with " + code;
                    return;
                }
                try {
                    root.tasks = root.order(JSON.parse(out).map(root.parse));
                    root.error = "";
                    root.loaded = true;
                } catch (e) {
                    root.error = "Could not read task export: " + e;
                }
            });
    }

    // ─── Changing ────────────────────────────────────────────────────────────

    /** Split on whitespace so Taskwarrior sees due:fri, +tag, project:x as attributes. */
    function words(text) {
        return String(text).trim().split(/\s+/).filter(w => w.length);
    }

    /** Runs a change, then re-reads the list. */
    function change(args) {
        run(args, function(code, out, err) {
            if (code !== 0)
                root.error = err || "task exited with " + code;
        });
        refresh();
    }

    /** "renew argo token due:fri +work pri:H": the attributes are parsed, the rest is the title. */
    function add(text) {
        if (words(text).length)
            change(["add"].concat(words(text)));
    }
    function complete(t) { change([t.uuid, "done"]); }
    function reopen(t) { change([t.uuid, "modify", "status:pending"]); }
    function toggleDone(t) { t.status === "completed" ? reopen(t) : complete(t); }
    function toggleStart(t) { if (t.status === "pending") change([t.uuid, t.start ? "stop" : "start"]); }
    /** New title, taken literally (after --) so a ":" or "+" in it stays text. */
    function rename(t, title) { if (title.trim().length) change([t.uuid, "modify", "--", title.trim()]); }
    /** Free-form modifiers: "due:mon +k8s -work project:bank pri:L". */
    function modify(t, text) { if (words(text).length) change([t.uuid, "modify"].concat(words(text))); }
    function annotate(t, text) { if (text.trim().length) change([t.uuid, "annotate", "--", text.trim()]); }
    function denotate(t, note) { change([t.uuid, "denotate", "--", note.text]); }
    function remove(t) { change([t.uuid, "delete"]); }
    function undo() { change(["undo"]); }

    // ─── Queue ───────────────────────────────────────────────────────────────

    property var queue: []
    property var current: null

    /** Queue `task <rc> args…`; `done(code, stdout, stderr)` runs when it finishes. */
    function run(args, done) {
        queue.push({ args: args, done: done });
        pump();
    }

    function pump() {
        if (proc.running || queue.length === 0)
            return;
        current = queue.shift();
        proc.command = ["sh", "-c", wrapper, "sh"].concat(rc, current.args);
        proc.running = true;
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text;
                var b = raw.lastIndexOf("\x1e");
                var a = raw.lastIndexOf("\x1e", b - 1);
                var job = root.current;
                root.current = null;
                if (job && job.done) {
                    if (a < 0)
                        job.done(1, "", "task did not run");
                    else
                        job.done(parseInt(raw.slice(a + 1, b)), raw.slice(0, a), raw.slice(b + 1).trim());
                }
                Qt.callLater(root.pump);
            }
        }
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
