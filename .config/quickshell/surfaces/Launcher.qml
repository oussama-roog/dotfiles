pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../widgets"

/**
 * Launcher surface: search field over a ranked list, drawn as one of the
 * pill's surfaces. A leading character picks what the list holds:
 *
 *   (none)  applications, ranked by match quality (name prefix, substring,
 *           subsequence over name / generic name / keywords), then by how
 *           often you launched them
 *   =       calculator (qalc); Enter copies the result
 *   >       shell actions: open a surface, lock, screenshot, random theme…
 *   :       niri keybinds read from config.kdl; Enter runs the bind
 *   .       emoji, from Unicode's emoji-test.txt (the unicode-emoji package,
 *           linked into ~/.local/share by home-manager); Enter copies
 *   +       add a Taskwarrior task (`+ renew cert due:fri +work`); Enter adds
 *
 * Every mode turns into the same row shape — { title, sub, glyph | emoji |
 * entry, run } — so one list and one delegate draw them all.
 */
PillSurface {
    id: root

    mTop: 15
    mLeft: 11
    mRight: 11
    mBottom: 14

    property string query: ""
    property int selectedIndex: 0
    property var usage: ({})

    /**
     * Window-coordinate position of the last hover event that was allowed to
     * move the selection. Rows sliding under a stationary cursor during
     * keyboard scrolling produce hover events at an unchanged window position,
     * which must not steal the keyboard selection.
     */
    property point lastPointer: Qt.point(-1, -1)

    readonly property string usageFile: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/quickshell/launcher-usage.json"

    readonly property var modes: ({
        "=": { name: "calc", icon: Icons.equals, hint: "Calculate" },
        ">": { name: "actions", icon: Icons.actions, hint: "Run an action" },
        ":": { name: "binds", icon: Icons.keyboard, hint: "Search keybinds" },
        ".": { name: "emoji", icon: Icons.smiley, hint: "Search emoji" },
        "+": { name: "task", icon: Icons.plus, hint: "Add a task" }
    })
    readonly property var modeInfo: modes[query.charAt(0)] || null
    readonly property string mode: modeInfo ? modeInfo.name : "apps"
    /** The query without its prefix. */
    readonly property string term: (modeInfo ? query.slice(1) : query).trim().toLowerCase()

    readonly property var allEntries: {
        var src = DesktopEntries.applications.values;
        var out = [];
        for (var i = 0; i < src.length; i++)
            if (src[i] && !src[i].noDisplay) out.push(src[i]);
        return out;
    }

    readonly property var results: {
        switch (mode) {
        case "calc": return calcItems;
        case "actions": return rank(actionItems, term, a => [a.title, a.sub], () => 0);
        case "binds": return rank(bindItems, term, b => [b.title, b.sub], () => 0);
        case "emoji": return term.length ? rank(emojiItems, term, e => [e.title, e.sub], () => 0).slice(0, 80) : emojiItems.slice(0, 80);
        case "task": return taskItems;
        }
        return rank(allEntries, term, e => [e.name, e.genericName].concat(e.keywords || []), e => usage[e.id] || 0)
            .map(e => ({ entry: e, title: e.name, sub: secondaryOf(e) }));
    }

    readonly property string counter: mode === "apps" ? results.length + " / " + allEntries.length
        : mode === "calc" || mode === "task" ? "" : String(results.length)

    /** 0 = first field starts with q, 1 = a field contains q, 2 = subsequence, 99 = no match. */
    function score(fields, q) {
        if (String(fields[0] || "").toLowerCase().indexOf(q) === 0)
            return 0;
        var best = 99;
        for (var i = 0; i < fields.length; i++) {
            var f = String(fields[i] || "").toLowerCase();
            if (f.indexOf(q) !== -1)
                return 1;
            var j = 0;
            for (var k = 0; k < f.length && j < q.length; k++)
                if (f[k] === q[j]) j++;
            if (j === q.length)
                best = 2;
        }
        return best;
    }

    /** Matches by `fieldsOf`, ordered by score, then `weightOf` (higher first), then title. */
    function rank(items, q, fieldsOf, weightOf) {
        var scored = [];
        for (var i = 0; i < items.length; i++) {
            var sc = q.length ? score(fieldsOf(items[i]), q) : 0;
            if (sc < 99)
                scored.push({ it: items[i], s: sc, w: weightOf(items[i]), n: String(fieldsOf(items[i])[0] || "").toLowerCase() });
        }
        scored.sort((a, b) => a.s - b.s || b.w - a.w || a.n.localeCompare(b.n));
        return scored.map(x => x.it);
    }

    function focusField() { search.input.forceActiveFocus(); }

    function secondaryOf(e) {
        if (e.genericName && e.genericName.length > 0)
            return e.genericName;
        return e.categories && e.categories.length > 0 ? mapCategory(e.categories) : "";
    }

    function mapCategory(raw) {
        const order = [
            ["TerminalEmulator", "Terminal"], ["WebBrowser", "Browser"],
            ["InstantMessaging", "Chat"], ["Audio", "Media"], ["AudioVideo", "Media"],
            ["Video", "Media"], ["Game", "Game"], ["Development", "Dev"],
            ["Graphics", "Graphics"], ["Office", "Office"], ["Settings", "System"],
            ["System", "System"], ["Utility", "Tool"], ["Network", "Net"]
        ];
        const cats = String(raw).split(/[;,]/);
        for (let i = 0; i < order.length; i++)
            if (cats.includes(order[i][0]))
                return order[i][1];
        return "";
    }

    function move(delta) {
        if (results.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
        list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function activate() {
        var item = results[selectedIndex];
        if (!item)
            return;
        if (item.entry) {
            if (item.entry.id) {
                usage[item.entry.id] = (usage[item.entry.id] || 0) + 1;
                usageStore.setText(JSON.stringify(usage));
            }
            item.entry.execute();
        } else if (item.run) {
            item.run();
        }
        root.requestClose();
    }

    function copy(text) {
        Quickshell.execDetached(["wl-copy", "--", text]);
    }

    function openSurface(name) {
        Quickshell.execDetached(["qs", "ipc", "call", "pill", name]);
    }

    onOpenChanged: {
        if (open) {
            query = "";
            search.text = "";
            selectedIndex = 0;
            Qt.callLater(root.focusField);
        }
    }
    onResultsChanged: if (selectedIndex >= results.length) selectedIndex = 0;

    FileView {
        id: usageStore
        path: root.usageFile
        blockLoading: true
        atomicWrites: true
        printErrors: false
    }

    Component.onCompleted: {
        var raw = usageStore.text();
        try {
            root.usage = raw && raw.length ? JSON.parse(raw) : ({});
        } catch (e) {
            root.usage = ({});
        }
    }

    // ─── = calculator ────────────────────────────────────────────────────────
    property var calcItems: []

    /** Debounced so qalc runs once you pause typing, not on every key. */
    Timer {
        id: calcDebounce
        interval: 120
        onTriggered: {
            if (root.term.length === 0) {
                root.calcItems = [];
                return;
            }
            calc.running = false;
            calc.command = ["qalc", "-t", "--", root.term];
            calc.running = true;
        }
    }
    onTermChanged: if (mode === "calc") calcDebounce.restart()
    onModeChanged: {
        if (mode === "calc")
            calcDebounce.restart();
        // The list may have appeared after the shell started (first rebuild).
        if (mode === "emoji" && emojiItems.length === 0)
            emojiFile.reload();
    }

    Process {
        id: calc
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim().split("\n").pop() || "";
                root.calcItems = out.length && !/^error/i.test(out)
                    ? [{ title: out, sub: root.term + "   ·   Enter copies", glyph: Icons.equals, run: () => root.copy(out) }]
                    : [];
            }
        }
    }

    // ─── > actions ───────────────────────────────────────────────────────────
    readonly property var actionItems: [
        { title: "Lock screen", sub: "loginctl lock-session", glyph: Icons.lock, run: () => Quickshell.execDetached(["loginctl", "lock-session"]) },
        { title: "Power menu", sub: "sleep, logout, restart, shutdown", glyph: Icons.shutdown, run: () => openSurface("power") },
        { title: "Screenshot", sub: "region, saved and copied", glyph: Icons.camera, run: () => Quickshell.execDetached([Quickshell.env("HOME") + "/dotfiles/scripts/screenshot.sh"]) },
        { title: "Clipboard history", sub: "Mod+V", glyph: Icons.clipboardText, run: () => openSurface("clipboard") },
        { title: "Notifications", sub: "Mod+N", glyph: Icons.bell, run: () => openSurface("notifications") },
        { title: "Agents", sub: "Claude and Antigravity sessions, plan usage · Mod+A", glyph: Icons.sparkle, run: () => openSurface("agents") },
        { title: "Tasks", sub: "Taskwarrior · Mod+T", glyph: Icons.listChecks, run: () => openSurface("tasks") },
        { title: "Web apps", sub: "Mod+W", glyph: Icons.globe, run: () => openSurface("web") },
        { title: "Themes", sub: "Mod+Shift+T", glyph: Icons.palette, run: () => openSurface("themes") },
        { title: "Random theme", sub: "base16", glyph: Icons.shuffle, run: () => Quickshell.execDetached([Quickshell.env("HOME") + "/dotfiles/scripts/theme-switcher.sh", "random"]) },
        { title: "Wallpapers", sub: "Mod+Shift+W", glyph: Icons.image, run: () => openSurface("wallpaper") },
        { title: Flags.dnd ? "Turn off do not disturb" : "Turn on do not disturb", sub: "notifications", glyph: Flags.dnd ? Icons.bell : Icons.bellSlash, run: () => Flags.dnd = !Flags.dnd },
        { title: "Reload shell", sub: "quickshell", glyph: Icons.reload, run: () => Quickshell.reload(true) }
    ]

    // ─── + task ──────────────────────────────────────────────────────────────
    /** The raw text (term is lowercased), handed to `task add` as typed. */
    readonly property var taskItems: {
        var text = query.slice(1).trim();
        return text.length
            ? [{ title: "Add task “" + text + "”", sub: "Taskwarrior  ·  due:fri  +tag  project:x  pri:H", glyph: Icons.listChecks, run: () => Taskwarrior.add(text) }]
            : [];
    }

    // ─── : niri binds ────────────────────────────────────────────────────────
    property var bindItems: []

    FileView {
        path: Quickshell.env("HOME") + "/.config/niri/config.kdl"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.bindItems = root.parseBinds(text())
    }

    /** Splits `"a" "b c" d` into ["a", "b c", "d"]. */
    function words(s) {
        var out = [], m, re = /"((?:[^"\\]|\\.)*)"|(\S+)/g;
        while ((m = re.exec(s)) !== null)
            out.push(m[1] !== undefined ? m[1].replace(/\\"/g, '"') : m[2]);
        return out;
    }

    /** One row per line of the `binds { }` block: `Keys [props] { action args; }`. */
    function parseBinds(kdl) {
        var block = kdl.match(/^binds\s*\{([\s\S]*?)^\}/m);
        if (!block)
            return [];
        var items = [];
        var lines = block[1].split("\n");
        for (var i = 0; i < lines.length; i++) {
            var m = lines[i].match(/^\s*([^\s\/{][^{]*?)\s*\{\s*([^;}]+);?\s*\}/);
            if (!m)
                continue;
            var keys = m[1].replace(/\s+[\w-]+=\S+/g, "");
            var w = words(m[2]);
            items.push({ title: describeBind(w), sub: keys, glyph: Icons.keyboard, run: runBind(w) });
        }
        return items;
    }

    function describeBind(w) {
        var action = w[0], args = w.slice(1);
        if (action === "spawn" && args.slice(0, 4).join(" ") === "qs ipc call pill")
            return "Open " + args[4];
        if (action === "spawn")
            return "Run " + args.map(a => a.replace(/^~\/(dotfiles\/)?(\.config\/)?/, "")).join(" ");
        if (action === "spawn-sh")
            return "Run " + args.join(" ");
        var text = action.replace(/-/g, " ") + (args.length ? " " + args.join(" ") : "");
        return text.charAt(0).toUpperCase() + text.slice(1);
    }

    function runBind(w) {
        var action = w[0], args = w.slice(1);
        if (action === "spawn")
            return () => Quickshell.execDetached(args.map(a => a.replace(/^~\//, Quickshell.env("HOME") + "/")));
        if (action === "spawn-sh")
            return () => Quickshell.execDetached(["sh", "-c", args.join(" ")]);
        // `--` keeps values like "-10%" from reading as flags.
        return () => Quickshell.execDetached(["niri", "msg", "action", action].concat(args.length ? ["--"].concat(args) : []));
    }

    // ─── . emoji ─────────────────────────────────────────────────────────────
    property var emojiItems: []

    /**
     * Fully-qualified emoji from emoji-test.txt, without the skin-tone variants
     * and the bare components. Lines look like:
     *   1F525 ; fully-qualified # 🔥 E0.6 fire
     */
    FileView {
        id: emojiFile
        path: (Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share") + "/unicode/emoji/emoji-test.txt"
        printErrors: false
        onLoaded: {
            const items = [];
            let group = "";
            for (const line of text().split("\n")) {
                if (line.startsWith("# group:")) {
                    group = line.slice(8).trim();
                    continue;
                }
                const m = line.match(/^[0-9A-F ]+;\s*fully-qualified\s*#\s*(\S+)\s+E[\d.]+\s+(.+)$/);
                if (!m || group === "Component" || m[2].indexOf("skin tone") >= 0)
                    continue;
                const emoji = m[1];
                items.push({ emoji: emoji, title: m[2], sub: group, run: () => root.copy(emoji) });
            }
            root.emojiItems = items;
        }
    }

    // ─── View ────────────────────────────────────────────────────────────────
    SearchField {
        id: search
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        s: root.s
        kanji: "探"
        icon: root.modeInfo ? root.modeInfo.icon : Icons.search
        placeholder: "Search apps   ·   = calc   > actions   : binds   . emoji"
        counterText: root.counter
        onTextChanged: {
            root.query = text;
            root.selectedIndex = 0;
        }
        onMoved: (d) => root.move(d)
        onAccepted: root.activate()
        onDismissed: root.requestClose()
    }

    Text {
        anchors.centerIn: list
        visible: root.results.length === 0
        text: root.mode === "emoji" && root.emojiItems.length === 0 ? "Emoji list missing: rebuild so home-manager links emoji-test.txt"
            : root.mode === "calc" ? (root.term.length ? "No result" : "Type an expression: 2^10, 15% * 80, 5 km to mi")
            : root.modeInfo && root.term.length === 0 ? root.modeInfo.hint
            : root.query.length ? "No matches" : "No apps found"
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: 10.5 * root.s
    }

    ListView {
        id: list
        anchors.top: search.bottom
        anchors.topMargin: 8 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 5 * root.s
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: root.results.length

        readonly property real rowH: 38 * root.s

        ElasticHighlight {
            parent: list.contentItem
            z: -1
            tx: 0
            ty: root.selectedIndex * (list.rowH + list.spacing)
            tw: list.width
            th: list.rowH
            radius: 12 * root.s
            shown: root.results.length > 0
        }

        delegate: Item {
            id: row
            required property int index
            width: list.width
            height: list.rowH

            readonly property var item: root.results[index]
            readonly property bool selected: index === root.selectedIndex

            MouseArea {
                id: rowArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: (m) => {
                    var g = rowArea.mapToItem(null, m.x, m.y);
                    if (g.x !== root.lastPointer.x || g.y !== root.lastPointer.y) {
                        root.lastPointer = Qt.point(g.x, g.y);
                        root.selectedIndex = row.index;
                    }
                }
                onClicked: {
                    root.selectedIndex = row.index;
                    root.activate();
                }
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 11 * root.s
                anchors.rightMargin: 11 * root.s

                /** App icon, emoji, or a glyph tile — whichever the row carries. */
                Rectangle {
                    id: iconBg
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22 * root.s
                    height: 22 * root.s
                    radius: 5 * root.s
                    color: row.selected ? Qt.alpha(Theme.onAccent, 0.12) : Theme.frameBg
                    visible: !appIcon.visible && !(row.item && row.item.emoji)

                    Icon {
                        anchors.centerIn: parent
                        size: 13 * root.s
                        text: row.item && row.item.glyph ? row.item.glyph : ""
                        color: row.selected ? Theme.onAccent : Theme.icon
                    }
                }
                Image {
                    id: appIcon
                    anchors.fill: iconBg
                    sourceSize.width: Math.round(40 * root.s)
                    sourceSize.height: Math.round(40 * root.s)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    visible: status === Image.Ready && source != ""
                    source: row.item && row.item.entry && row.item.entry.icon ? Quickshell.iconPath(row.item.entry.icon, true) : ""
                }
                Text {
                    anchors.centerIn: iconBg
                    visible: !!(row.item && row.item.emoji)
                    text: row.item && row.item.emoji ? row.item.emoji : ""
                    font.pixelSize: 17 * root.s
                }

                TextMetrics {
                    id: retMetrics
                    font.family: Theme.font
                    font.pixelSize: 12 * root.s
                    text: "↵"
                }
                Text {
                    id: ret
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    text: retMetrics.text
                    color: Theme.onAccent
                    font.family: Theme.font
                    font.pixelSize: 12 * root.s
                    visible: row.selected
                    width: visible ? retMetrics.advanceWidth + 6 * root.s : 0
                    horizontalAlignment: Text.AlignRight
                }

                /**
                 * Title over description, each clipped on its own line, so a long
                 * description can't bleed into the title. The block centres on the
                 * icon whether it shows one line or two.
                 */
                Column {
                    anchors.left: iconBg.right
                    anchors.leftMargin: 10 * root.s
                    anchors.right: ret.left
                    anchors.rightMargin: 8 * root.s
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1 * root.s

                    Text {
                        width: parent.width
                        text: row.item ? row.item.title : ""
                        color: row.selected ? Theme.onAccent : Theme.text
                        font.family: Theme.font
                        font.pixelSize: 13 * root.s
                        font.weight: row.selected ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                    Text {
                        width: parent.width
                        visible: text.length > 0
                        text: row.item && row.item.sub ? row.item.sub : ""
                        color: row.selected ? Qt.alpha(Theme.onAccent, 0.65) : Theme.textFaint
                        font.family: root.mode === "binds" ? "monospace" : Theme.font
                        font.pixelSize: 10.5 * root.s
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                }
            }
        }
    }
}
