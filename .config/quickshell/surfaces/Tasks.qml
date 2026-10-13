pragma ComponentBehavior: Bound

import QtQuick
import "../services"
import "../widgets"

/**
 * Tasks centre (Mod+T): Taskwarrior in two columns, the list on the left and
 * the selected task's details and notes on the right. Opening it reads the
 * list fresh (Taskwarrior.refresh()); nothing is watched.
 *
 *   field     filters the list as you type. With text in it the first row is
 *             "Add …": Enter adds it, and Taskwarrior's own syntax works
 *             (`renew cert due:fri +work project:infra pri:H`). The same field
 *             turns into the editor for Ctrl+E / Ctrl+M / Ctrl+N.
 *   filters   All · Today (due or overdue) · one per project · Done; switch
 *             with Left/Right (while the field is empty), Ctrl+H/Ctrl+L or
 *             Tab/Shift+Tab, as in the agents centre. All ends with this week's done tasks,
 *             folded under a header.
 *   list      sorted by urgency; a circle to tick, title, project, tags, notes,
 *             time on a started task, priority flag and a due badge.
 *   details   status, title, fields, notes (hover a note to drop it) and an
 *             action bar; the add row shows a syntax cheat sheet instead.
 *
 * Keys: Up/Down (Ctrl+J/K) move, Enter adds or ticks the selected row,
 * Ctrl+D done/reopen, Ctrl+S start/stop, Ctrl+E edit title, Ctrl+M modify,
 * Ctrl+N add a note, Ctrl+X delete, Ctrl+Z undo, Esc clears, cancels, closes.
 */
PillSurface {
    id: root

    mTop: 15
    mLeft: 17
    mRight: 17
    mBottom: 15

    property string query: ""
    /** "search", or the field is editing the selected task: "rename", "modify", "note". */
    property string mode: "search"
    property string savedQuery: ""
    /** Set while leaveEdit() puts the filter text back, so the selection survives. */
    property bool restoring: false
    property string filter: "all"
    property bool doneOpen: false

    property int selectedIndex: 0
    property string selectedUuid: ""
    property point lastPointer: Qt.point(-1, -1)

    readonly property real rowH: 46 * s
    readonly property real headerH: 30 * s

    // ─── Data ────────────────────────────────────────────────────────────────

    function isToday(t) {
        return t.due !== null && Taskwarrior.dayDiff(t.due) <= 0;
    }

    readonly property var projects: {
        var counts = {};
        Taskwarrior.pending.forEach(t => { if (t.project) counts[t.project] = (counts[t.project] || 0) + 1; });
        return Object.keys(counts).sort((a, b) => counts[b] - counts[a] || a.localeCompare(b)).slice(0, 4)
            .map(p => ({ key: "p:" + p, label: p, count: counts[p] }));
    }

    readonly property var filters: [
        { key: "all", label: "All", count: Taskwarrior.pending.length },
        { key: "today", label: "Today", count: Taskwarrior.pending.filter(isToday).length }
    ].concat(projects, [{ key: "done", label: "Done", count: Taskwarrior.done.length }])

    readonly property int overdue: Taskwarrior.pending.filter(t => t.due && Taskwarrior.dayDiff(t.due) < 0).length
    readonly property int dueToday: Taskwarrior.pending.filter(t => t.due && Taskwarrior.dayDiff(t.due) === 0).length
    readonly property var active: Taskwarrior.pending.filter(t => t.start !== null)

    function matches(t, q) {
        if (!q.length)
            return true;
        var hay = [t.title, t.project].concat(t.tags, t.notes.map(n => n.text)).join(" ").toLowerCase();
        return hay.indexOf(q) !== -1;
    }

    /** Rows of the list: { kind: "add" | "task" | "header", task?, text? }. */
    readonly property var rows: {
        var q = query.trim().toLowerCase();
        var out = [];
        if (q.length)
            out.push({ kind: "add", text: query.trim() });
        var src = filter === "done" ? Taskwarrior.done
            : filter === "today" ? Taskwarrior.pending.filter(isToday)
            : filter.indexOf("p:") === 0 ? Taskwarrior.pending.filter(t => t.project === filter.slice(2))
            : Taskwarrior.pending;
        src.filter(t => matches(t, q)).forEach(t => out.push({ kind: "task", task: t }));
        if (filter === "all") {
            var done = Taskwarrior.done.filter(t => matches(t, q));
            if (done.length) {
                out.push({ kind: "header", count: done.length });
                if (doneOpen)
                    done.forEach(t => out.push({ kind: "task", task: t }));
            }
        }
        return out;
    }

    readonly property var selRow: rows[selectedIndex] || null
    readonly property var sel: selRow && selRow.kind === "task" ? selRow.task : null

    function heightOf(row) {
        return row && row.kind === "header" ? headerH : rowH;
    }

    function rowY(index) {
        var y = 0;
        for (var i = 0; i < index && i < rows.length; i++)
            y += heightOf(rows[i]) + list.spacing;
        return y;
    }

    // ─── Selection ───────────────────────────────────────────────────────────

    function select(i) {
        selectedIndex = Math.max(0, Math.min(rows.length - 1, i));
        var r = rows[selectedIndex];
        selectedUuid = r && r.kind === "task" ? r.task.uuid : "";
        if (list)
            list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function move(delta) {
        if (rows.length)
            select(selectedIndex + delta);
    }

    /** Keep the same task selected across refreshes; if it left the view, stay at its place. */
    onRowsChanged: {
        if (selectedUuid.length) {
            for (var i = 0; i < rows.length; i++)
                if (rows[i].kind === "task" && rows[i].task.uuid === selectedUuid) {
                    selectedIndex = i;
                    return;
                }
        }
        select(selectedIndex);
    }

    function cycleFilter(dir) {
        var i = filters.findIndex(f => f.key === filter);
        filter = filters[(i + dir + filters.length) % filters.length].key;
        selectedUuid = "";
        select(0);
    }

    function setFilter(key) {
        filter = key;
        selectedUuid = "";
        select(0);
        focusField();
    }

    // ─── Actions ─────────────────────────────────────────────────────────────

    function focusField() { search.input.forceActiveFocus(); }

    function activate() {
        var r = selRow;
        if (!r)
            return;
        if (r.kind === "add") {
            Taskwarrior.add(r.text);
            search.text = "";
        } else if (r.kind === "header") {
            doneOpen = !doneOpen;
        } else {
            Taskwarrior.toggleDone(r.task);
        }
    }

    /** Turn the field into an editor for the selected task. */
    function edit(m) {
        if (!sel || (m === "modify" && sel.status !== "pending"))
            return;
        savedQuery = query;
        mode = m;
        search.text = m === "rename" ? sel.title : "";
        search.input.selectAll();
        focusField();
    }

    function leaveEdit() {
        mode = "search";
        restoring = true;
        search.text = savedQuery;
        restoring = false;
        focusField();
    }

    function commit() {
        var t = sel;
        var text = search.text;
        if (t) {
            if (mode === "rename") Taskwarrior.rename(t, text);
            else if (mode === "modify") Taskwarrior.modify(t, text);
            else if (mode === "note") Taskwarrior.annotate(t, text);
        }
        leaveEdit();
    }

    onOpenChanged: {
        if (open) {
            mode = "search";
            query = "";
            search.text = "";
            filter = "all";
            doneOpen = false;
            selectedUuid = "";
            selectedIndex = 0;
            Taskwarrior.refresh();
            Qt.callLater(root.focusField);
        }
    }

    // ─── Pieces ──────────────────────────────────────────────────────────────

    /** Small caps label, the inbox header's style. */
    component Label: Text {
        color: Theme.textSubtle
        font.family: Theme.font
        font.pixelSize: 9.5 * root.s
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1.5 * root.s
    }

    component Hair: Rectangle {
        width: parent ? parent.width : 0
        height: 1
        color: Theme.hair
    }

    /** Glyph plus text, the bits on a row's second line. */
    component Meta: Row {
        id: meta
        property string icon: ""
        property string text: ""
        property color color: Theme.textDim

        spacing: 4 * root.s
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            size: 10 * root.s
            text: meta.icon
            color: meta.color
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: meta.text
            color: meta.color
            font.family: Theme.font
            font.pixelSize: 10 * root.s
            font.features: { "tnum": 1 }
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 130 * root.s)
        }
    }

    /** Due badge: filled for overdue, tinted for today, quiet otherwise. */
    component DueBadge: Rectangle {
        id: badge
        property var task: null
        property bool onAccent: false
        readonly property int diff: task && task.due ? Taskwarrior.dayDiff(task.due) : 99
        readonly property bool doneTask: task !== null && task.status === "completed"
        readonly property bool late: !doneTask && diff < 0
        readonly property bool today: !doneTask && diff === 0

        visible: task !== null && (doneTask ? task.end !== null : task.due !== null)
        width: visible ? badgeText.implicitWidth + 14 * root.s : 0
        height: 18 * root.s
        radius: height / 2
        color: onAccent ? Qt.alpha(Theme.onAccent, late ? 0.22 : 0.12)
            : late ? Theme.accent
            : today ? Qt.alpha(Theme.accent, 0.16)
            : Theme.frameBg
        border.width: onAccent || late ? 0 : 1
        border.color: today ? Qt.alpha(Theme.accent, 0.35) : Theme.frameBorder

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: !badge.visible ? "" : badge.doneTask ? "done " + Taskwarrior.dueShort(badge.task.end) : Taskwarrior.dueShort(badge.task.due)
            color: badge.onAccent ? Theme.onAccent
                : badge.late ? Theme.onAccent
                : badge.today ? Theme.accent
                : badge.doneTask ? Theme.textFaint : Theme.textSubtle
            font.family: Theme.font
            font.pixelSize: 9.5 * root.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
        }
    }

    /** One field in the details grid: glyph, small label, value. */
    component Field: Item {
        id: field
        property string icon: ""
        property string label: ""
        property string value: ""
        property color valueColor: Theme.text

        height: 34 * root.s

        Rectangle {
            id: fieldTile
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 26 * root.s
            height: width
            radius: 8 * root.s
            color: Theme.frameBg
            border.width: 1
            border.color: Theme.frameBorder

            Icon {
                anchors.centerIn: parent
                size: 13 * root.s
                text: field.icon
                color: Theme.icon
            }
        }

        Column {
            anchors.left: fieldTile.right
            anchors.leftMargin: 9 * root.s
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1 * root.s

            Text {
                text: field.label
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: 9 * root.s
                font.weight: Font.DemiBold
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1 * root.s
            }
            Text {
                width: parent.width
                text: field.value.length ? field.value : "—"
                color: field.value.length ? field.valueColor : Theme.textFaint
                font.family: Theme.font
                font.pixelSize: 11.5 * root.s
                font.weight: Font.Medium
                font.features: { "tnum": 1 }
                elide: Text.ElideRight
            }
        }
    }

    /** Action bar button: glyph and label, its keys in a tooltip. `hold` makes it hold-to-confirm. */
    component ActionButton: Rectangle {
        id: btn
        property string icon: ""
        property string label: ""
        property string keys: ""
        property bool hold: false
        property bool hot: false
        signal triggered()

        readonly property bool hovered: btnArea.containsMouse
        readonly property real heat: heatHold.hold

        width: btnRow.implicitWidth + 16 * root.s
        height: 28 * root.s
        radius: 9 * root.s
        color: hot ? Qt.alpha(Theme.accent, 0.16) : hovered ? Qt.alpha(Theme.text, 0.09) : Theme.frameBg
        border.width: 1
        border.color: hot ? Qt.alpha(Theme.accent, 0.35) : Theme.frameBorder
        Behavior on color { ColorAnimation { duration: Motion.fast } }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(height, parent.width * btn.heat)
            radius: parent.radius
            visible: btn.heat > 0.001
            color: Qt.alpha(Theme.accent, 0.35)
        }

        Row {
            id: btnRow
            anchors.centerIn: parent
            spacing: 6 * root.s

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                size: 12 * root.s
                text: btn.icon
                color: btn.hot || btn.heat > 0 ? Theme.accent : btn.hovered ? Theme.text : Theme.icon
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: btn.label
                color: btn.hot ? Theme.accent : btn.hovered ? Theme.textBright : Theme.text
                font.family: Theme.font
                font.pixelSize: 10.5 * root.s
                font.weight: Font.DemiBold
            }
        }

        HeatHold {
            id: heatHold
            onConfirmed: btn.triggered()
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: if (btn.hold) heatHold.press()
            onReleased: if (btn.hold) heatHold.release()
            onExited: if (btn.hold) heatHold.cancel()
            onClicked: if (!btn.hold) btn.triggered()
        }

        Tooltip {
            s: root.s
            title: btn.keys
            show: btn.keys.length > 0 && btn.hovered
        }
    }

    // ─── Field ───────────────────────────────────────────────────────────────

    SearchField {
        id: search
        z: 5
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        s: root.s
        kanji: root.mode === "search" ? "務" : "記"
        icon: root.mode === "rename" ? Icons.pencil
            : root.mode === "modify" ? Icons.sliders
            : root.mode === "note" ? Icons.notePencil
            : Icons.listChecks
        placeholder: root.mode === "modify" ? "due:fri  +tag  -tag  project:name  pri:H  recur:weekly"
            : root.mode === "note" ? "Add a note to “" + (root.sel ? root.sel.title : "") + "”"
            : root.mode === "rename" ? "Title"
            : "Filter, or type a new task and press Enter"
        counterText: root.mode !== "search" ? "↵ save   esc cancel"
            : Taskwarrior.pending.length + " open"

        onTextChanged: {
            if (root.mode !== "search")
                return;
            root.query = text;
            if (root.restoring)
                return;
            root.selectedUuid = "";
            root.select(0);
        }
        onMoved: (d) => { if (root.mode === "search") root.move(d); }
        onAccepted: root.mode === "search" ? root.activate() : root.commit()
        onDismissed: {
            if (root.mode !== "search")
                root.leaveEdit();
            else if (text.length)
                text = "";
            else
                root.requestClose();
        }
        onKeyPressed: (e) => {
            if (root.mode !== "search")
                return;
            var ctrl = e.modifiers & Qt.ControlModifier;
            if (e.key === Qt.Key_Tab || e.key === Qt.Key_Backtab) {
                root.cycleFilter(e.key === Qt.Key_Backtab || (e.modifiers & Qt.ShiftModifier) ? -1 : 1);
            } else if (ctrl && (e.key === Qt.Key_H || e.key === Qt.Key_L)) {
                root.cycleFilter(e.key === Qt.Key_L ? 1 : -1);
            } else if ((e.key === Qt.Key_Left || e.key === Qt.Key_Right) && search.text.length === 0) {
                root.cycleFilter(e.key === Qt.Key_Right ? 1 : -1);
            } else if (ctrl && e.key === Qt.Key_D && root.sel) {
                Taskwarrior.toggleDone(root.sel);
            } else if (ctrl && e.key === Qt.Key_S && root.sel) {
                Taskwarrior.toggleStart(root.sel);
            } else if (ctrl && e.key === Qt.Key_E && root.sel) {
                root.edit("rename");
            } else if (ctrl && e.key === Qt.Key_M && root.sel) {
                root.edit("modify");
            } else if (ctrl && e.key === Qt.Key_N && root.sel) {
                root.edit("note");
            } else if (ctrl && e.key === Qt.Key_X && root.sel && search.input.selectedText.length === 0) {
                Taskwarrior.remove(root.sel);
            } else if (ctrl && e.key === Qt.Key_Z && search.text.length === 0) {
                Taskwarrior.undo();
            } else {
                return;
            }
            e.accepted = true;
        }

        Item {
            id: undoBtn
            anchors.verticalCenter: parent.verticalCenter
            width: 16 * root.s
            height: 16 * root.s
            visible: root.mode === "search"

            Icon {
                anchors.centerIn: parent
                size: 14 * root.s
                text: Icons.undo
                color: undoArea.containsMouse ? Theme.text : Theme.textFaint
            }
            MouseArea {
                id: undoArea
                anchors.fill: parent
                anchors.margins: -5 * root.s
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { Taskwarrior.undo(); root.focusField(); }
            }
            Tooltip {
                s: root.s
                placement: "below"
                title: "undo  ·  Ctrl+Z"
                show: undoArea.containsMouse
            }
        }
    }

    // ─── Filters + summary ───────────────────────────────────────────────────

    Item {
        id: filterBar
        anchors.top: search.bottom
        anchors.topMargin: 10 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        height: 28 * root.s

        Rectangle {
            id: chipsFrame
            anchors.left: parent.left
            width: chips.implicitWidth + 2 * chips.gap
            height: parent.height
            radius: height / 2
            color: Theme.frameBg
            border.width: 1
            border.color: Theme.frameBorder

            ElasticHighlight {
                readonly property var item: chipRepeater.count > 0
                    ? chipRepeater.itemAt(Math.max(0, root.filters.findIndex(f => f.key === root.filter))) : null
                tx: item ? chips.x + item.x : 0
                ty: chips.gap
                tw: item ? item.width : 0
                th: chipsFrame.height - 2 * chips.gap
                radius: 14 * root.s
                shown: item !== null
            }

            Row {
                id: chips
                readonly property real gap: 4 * root.s
                x: gap
                y: gap
                height: chipsFrame.height - 2 * gap
                spacing: gap

                Repeater {
                    id: chipRepeater
                    model: root.filters

                    Item {
                        id: chip
                        required property var modelData
                        readonly property bool selected: root.filter === modelData.key

                        width: chipRow.implicitWidth + 22 * root.s
                        height: chips.height

                        Row {
                            id: chipRow
                            anchors.centerIn: parent
                            spacing: 6 * root.s

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: chip.modelData.label
                                color: chip.selected ? Theme.onAccent : chipHover.hovered ? Theme.text : Theme.textSubtle
                                font.family: Theme.font
                                font.pixelSize: 11 * root.s
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, 96 * root.s)
                                Behavior on color { ColorAnimation { duration: Motion.fast } }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: chip.modelData.count > 0
                                text: chip.modelData.count
                                color: chip.selected ? Qt.alpha(Theme.onAccent, 0.75)
                                    : chip.modelData.key === "today" && root.overdue > 0 ? Theme.accent
                                    : Theme.textFaint
                                font.family: Theme.font
                                font.pixelSize: 9.5 * root.s
                                font.weight: Font.DemiBold
                                font.features: { "tnum": 1 }
                            }
                        }

                        HoverHandler { id: chipHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setFilter(chip.modelData.key)
                        }
                    }
                }
            }
        }

        /** Right of the chips: the error if the last command failed, else a one-line summary. */
        Item {
            anchors.left: chipsFrame.right
            anchors.leftMargin: 12 * root.s
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            clip: true

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 4 * root.s
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14 * root.s
                visible: Taskwarrior.error.length === 0

                Meta {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.active.length > 0
                    icon: Icons.play
                    text: root.active.length === 1 ? Taskwarrior.elapsed(root.active[0].start) + " on " + root.active[0].title
                        : root.active.length + " in progress"
                    color: Theme.accent
                }
                Meta {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.overdue > 0
                    icon: Icons.warning
                    text: root.overdue + " overdue"
                    color: Theme.accent
                }
                Meta {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.dueToday > 0
                    icon: Icons.calendar
                    text: root.dueToday + " due today"
                    color: Theme.textSubtle
                }
            }

            Meta {
                anchors.right: parent.right
                anchors.rightMargin: 4 * root.s
                anchors.verticalCenter: parent.verticalCenter
                visible: Taskwarrior.error.length > 0
                icon: Icons.warning
                text: Taskwarrior.error.split("\n")[0]
                color: Theme.accent
            }
        }
    }

    // ─── Body ────────────────────────────────────────────────────────────────

    Item {
        id: body
        anchors.top: filterBar.bottom
        anchors.topMargin: 10 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // ─── Left: the list ─────────────────────────────────────────────────
        Item {
            id: left
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.round(parent.width * 0.45)

            Column {
                anchors.centerIn: parent
                visible: root.rows.length === 0
                spacing: 8 * root.s

                Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    size: 34 * root.s
                    text: Taskwarrior.error.length && !Taskwarrior.loaded ? Icons.warning : Icons.listChecks
                    color: Theme.textFaint
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Taskwarrior.error.length && !Taskwarrior.loaded ? "Taskwarrior isn't ready"
                        : !Taskwarrior.loaded ? "Loading…"
                        : root.filter === "done" ? "Nothing done this week yet"
                        : root.filter === "all" ? "All clear"
                        : "Nothing here"
                    color: Theme.textSubtle
                    font.family: Theme.font
                    font.pixelSize: 13 * root.s
                    font.weight: Font.DemiBold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: left.width - 40 * root.s
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: Taskwarrior.error.length && !Taskwarrior.loaded ? Taskwarrior.error
                        : root.filter === "all" ? "Type a task above and press Enter" : ""
                    color: Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 10.5 * root.s
                }
            }

            ListView {
                id: list
                anchors.fill: parent
                spacing: 2 * root.s
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.rows.length

                ElasticHighlight {
                    parent: list.contentItem
                    z: -1
                    tx: 0
                    ty: root.rowY(root.selectedIndex)
                    tw: list.width
                    th: root.heightOf(root.rows[root.selectedIndex])
                    radius: 12 * root.s
                    shown: root.rows.length > 0
                }

                delegate: Item {
                    id: row
                    required property int index
                    readonly property var entry: root.rows[index] || ({ kind: "none" })
                    readonly property var task: entry.kind === "task" ? entry.task : null
                    readonly property bool selected: index === root.selectedIndex
                    readonly property bool isDone: task !== null && task.status === "completed"

                    width: list.width
                    height: root.heightOf(entry)

                    HoverHandler {
                        id: rowHover
                        onPointChanged: {
                            if (!hovered)
                                return;
                            var sp = point.scenePosition;
                            if (sp.x !== root.lastPointer.x || sp.y !== root.lastPointer.y) {
                                root.lastPointer = Qt.point(sp.x, sp.y);
                                root.select(row.index);
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: row.entry.kind === "task" ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: {
                            root.select(row.index);
                            if (row.entry.kind !== "task")
                                root.activate();
                            root.focusField();
                        }
                    }

                    // ─── header: "Done this week" fold ─────────────────────
                    Row {
                        visible: row.entry.kind === "header"
                        anchors.left: parent.left
                        anchors.leftMargin: 14 * root.s
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8 * root.s

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            size: 10 * root.s
                            text: root.doneOpen ? Icons.caretDown : Icons.caretRight
                            color: row.selected ? Theme.onAccent : Theme.textDim
                        }
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Done this week"
                            color: row.selected ? Theme.onAccent : Theme.textDim
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.entry.count || ""
                            color: row.selected ? Qt.alpha(Theme.onAccent, 0.7) : Theme.textFaint
                            font.family: Theme.font
                            font.pixelSize: 9.5 * root.s
                            font.weight: Font.DemiBold
                        }
                    }

                    // ─── add / task ───────────────────────────────────────
                    Item {
                        visible: row.entry.kind === "add" || row.entry.kind === "task"
                        anchors.fill: parent
                        anchors.leftMargin: 12 * root.s
                        anchors.rightMargin: 12 * root.s

                        /** Tick circle; on the add row a plus. Started tasks get an accent core. */
                        Item {
                            id: tick
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20 * root.s
                            height: 20 * root.s

                            readonly property color tone: row.selected ? Theme.onAccent
                                : row.isDone ? Theme.accent
                                : tickArea.containsMouse ? Theme.accent
                                : Theme.textDim

                            Icon {
                                anchors.centerIn: parent
                                size: 18 * root.s
                                text: row.entry.kind === "add" ? Icons.plus
                                    : row.isDone || tickArea.containsMouse ? Icons.checkCircle
                                    : Icons.circle
                                color: tick.tone
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                visible: row.task !== null && row.task.start !== null && !row.isDone && !tickArea.containsMouse
                                width: 7 * root.s
                                height: width
                                radius: width / 2
                                color: row.selected ? Theme.onAccent : Theme.accent
                                SequentialAnimation on opacity {
                                    running: root.open && row.task !== null && row.task.start !== null
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1; to: 0.35; duration: 900; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 0.35; to: 1; duration: 900; easing.type: Easing.InOutSine }
                                }
                            }
                            MouseArea {
                                id: tickArea
                                anchors.fill: parent
                                anchors.margins: -4 * root.s
                                enabled: row.task !== null
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { Taskwarrior.toggleDone(row.task); root.focusField(); }
                            }
                        }

                        Column {
                            anchors.left: tick.right
                            anchors.leftMargin: 11 * root.s
                            anchors.right: tail.left
                            anchors.rightMargin: 10 * root.s
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3 * root.s

                            Text {
                                width: parent.width
                                text: row.entry.kind === "add" ? "Add “" + row.entry.text + "”"
                                    : row.task ? row.task.title : ""
                                color: row.selected ? Theme.onAccent
                                    : row.isDone ? Theme.textFaint
                                    : Theme.text
                                font.family: Theme.font
                                font.pixelSize: 12.5 * root.s
                                font.weight: row.selected ? Font.DemiBold : Font.Medium
                                font.strikeout: row.isDone
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                            }

                            Row {
                                spacing: 10 * root.s
                                readonly property color tone: row.selected ? Qt.alpha(Theme.onAccent, 0.75) : Theme.textDim

                                Text {
                                    visible: row.entry.kind === "add"
                                    text: "Enter to add  ·  due:fri  +tag  project:x  pri:H"
                                    color: parent.tone
                                    font.family: Theme.font
                                    font.pixelSize: 10 * root.s
                                }
                                Meta {
                                    visible: row.task !== null && row.task.start !== null && !row.isDone
                                    icon: Icons.play
                                    text: row.task && row.task.start ? Taskwarrior.elapsed(row.task.start) : ""
                                    color: row.selected ? Theme.onAccent : Theme.accent
                                }
                                Meta {
                                    visible: row.task !== null && row.task.project.length > 0
                                    icon: Icons.folder
                                    text: row.task ? row.task.project : ""
                                    color: parent.tone
                                }
                                Meta {
                                    visible: row.task !== null && row.task.tags.length > 0
                                    icon: Icons.tag
                                    text: row.task ? row.task.tags.join(" ") : ""
                                    color: parent.tone
                                }
                                Meta {
                                    visible: row.task !== null && row.task.notes.length > 0
                                    icon: Icons.note
                                    text: row.task ? String(row.task.notes.length) : ""
                                    color: parent.tone
                                }
                                Meta {
                                    visible: row.task !== null && !row.task.project.length && !row.task.tags.length
                                        && !row.task.notes.length && !row.task.start
                                    icon: Icons.clock
                                    text: row.task && row.task.entry ? "added " + Taskwarrior.ago(row.task.entry) : ""
                                    color: row.selected ? Qt.alpha(Theme.onAccent, 0.6) : Theme.textFaint
                                }
                            }
                        }

                        Row {
                            id: tail
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8 * root.s

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: row.task !== null && row.task.priority.length > 0 && !row.isDone
                                size: 12 * root.s
                                text: Icons.flag
                                color: row.selected ? Theme.onAccent
                                    : row.task && row.task.priority === "H" ? Theme.accent
                                    : row.task && row.task.priority === "M" ? Theme.textSubtle
                                    : Theme.textFaint
                            }
                            DueBadge {
                                anchors.verticalCenter: parent.verticalCenter
                                task: row.task
                                onAccent: row.selected
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: row.entry.kind === "add"
                                text: "↵"
                                color: row.selected ? Theme.onAccent : Theme.textFaint
                                font.family: Theme.font
                                font.pixelSize: 13 * root.s
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: split
            anchors.left: left.right
            anchors.leftMargin: 14 * root.s
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: Theme.hair
        }

        // ─── Right: details ─────────────────────────────────────────────────
        Item {
            id: right
            anchors.left: split.right
            anchors.leftMargin: 18 * root.s
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            readonly property var t: root.sel
            readonly property bool isDone: t !== null && t.status === "completed"
            readonly property int diff: t && t.due ? Taskwarrior.dayDiff(t.due) : 99

            // ─── task ─────────────────────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: right.t !== null

                Flickable {
                    id: detailFlick
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: actions.top
                    anchors.bottomMargin: 10 * root.s
                    contentHeight: detailCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentHeight > height

                    WheelScroller {
                        anchors.fill: parent
                        s: root.s
                        flick: detailFlick
                    }

                    Column {
                        id: detailCol
                        width: detailFlick.width
                        spacing: 12 * root.s

                        Column {
                            width: parent.width
                            spacing: 5 * root.s

                            Row {
                                spacing: 6 * root.s
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 6 * root.s
                                    height: width
                                    radius: width / 2
                                    color: statusLabel.color
                                }
                                Label {
                                    id: statusLabel
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: !right.t ? ""
                                        : right.isDone ? "Completed  " + Qt.formatDate(right.t.end, "ddd d MMM")
                                        : right.t.start ? "In progress  ·  " + Taskwarrior.elapsed(right.t.start)
                                        : right.diff < 0 ? "Overdue"
                                        : right.diff === 0 ? "Due today"
                                        : "Pending"
                                    color: right.isDone ? Theme.textDim
                                        : right.t && (right.t.start || right.diff <= 0) ? Theme.accent
                                        : Theme.textSubtle
                                }
                            }

                            Text {
                                width: parent.width
                                text: right.t ? right.t.title : ""
                                color: right.isDone ? Theme.textDim : Theme.textBright
                                font.family: Theme.font
                                font.pixelSize: 17 * root.s
                                font.weight: Font.DemiBold
                                font.strikeout: right.isDone
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                lineHeight: 1.1
                            }
                        }

                        Grid {
                            id: fields
                            width: parent.width
                            columns: 2
                            columnSpacing: 12 * root.s
                            rowSpacing: 6 * root.s
                            readonly property real cellW: (width - columnSpacing) / 2

                            Field {
                                width: fields.cellW
                                icon: Icons.calendar
                                label: "Due"
                                value: right.t && right.t.due ? Taskwarrior.dueLong(right.t.due) : ""
                                valueColor: !right.isDone && right.diff <= 0 ? Theme.accent : Theme.text
                            }
                            Field {
                                width: fields.cellW
                                icon: Icons.folder
                                label: "Project"
                                value: right.t ? right.t.project : ""
                            }
                            Field {
                                width: fields.cellW
                                icon: Icons.tag
                                label: "Tags"
                                value: right.t ? right.t.tags.map(x => "+" + x).join("  ") : ""
                            }
                            Field {
                                width: fields.cellW
                                icon: Icons.flag
                                label: "Priority"
                                value: !right.t ? "" : ({ H: "High", M: "Medium", L: "Low" })[right.t.priority] || ""
                                valueColor: right.t && right.t.priority === "H" ? Theme.accent : Theme.text
                            }
                            Field {
                                width: fields.cellW
                                icon: Icons.clock
                                label: "Created"
                                value: right.t && right.t.entry ? Qt.formatDate(right.t.entry, "ddd d MMM") + "  ·  " + Taskwarrior.ago(right.t.entry) : ""
                            }
                            Field {
                                width: fields.cellW
                                icon: right.t && right.t.recur ? Icons.reload : Icons.hourglass
                                label: right.t && right.t.recur ? "Repeats" : "Urgency"
                                value: !right.t ? "" : right.t.recur ? right.t.recur : right.t.urgency.toFixed(1)
                            }
                        }

                        Hair {}

                        Item {
                            width: parent.width
                            height: notesLabel.implicitHeight

                            Row {
                                spacing: 8 * root.s
                                Label { id: notesLabel; text: "Notes" }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: right.t !== null && right.t.notes.length > 0
                                    text: right.t ? right.t.notes.length : ""
                                    color: Theme.textFaint
                                    font.family: Theme.font
                                    font.pixelSize: 9.5 * root.s
                                    font.weight: Font.DemiBold
                                }
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Ctrl+N to add"
                                color: Theme.textFaint
                                font.family: Theme.font
                                font.pixelSize: 9.5 * root.s
                            }
                        }

                        Text {
                            visible: right.t !== null && right.t.notes.length === 0
                            text: "No notes yet"
                            color: Theme.textFaint
                            font.family: Theme.font
                            font.pixelSize: 11 * root.s
                            font.italic: true
                        }

                        /** Notes as a small timeline: dot, timestamp, text; hover to drop one. */
                        Column {
                            width: parent.width
                            spacing: 10 * root.s

                            Repeater {
                                model: right.t ? right.t.notes : []

                                Item {
                                    id: noteItem
                                    required property var modelData
                                    required property int index
                                    width: parent.width
                                    height: noteCol.implicitHeight

                                    HoverHandler { id: noteHover }

                                    Rectangle {
                                        id: noteDot
                                        x: 2 * root.s
                                        y: 4 * root.s
                                        width: 6 * root.s
                                        height: width
                                        radius: width / 2
                                        color: noteHover.hovered ? Theme.accent : Theme.textFaint
                                    }
                                    Rectangle {
                                        visible: noteItem.index < (right.t ? right.t.notes.length - 1 : 0)
                                        x: noteDot.x + noteDot.width / 2
                                        anchors.top: noteDot.bottom
                                        anchors.topMargin: 3 * root.s
                                        height: noteItem.height + 2 * root.s
                                        width: 1
                                        color: Theme.hair
                                    }

                                    Column {
                                        id: noteCol
                                        anchors.left: parent.left
                                        anchors.leftMargin: 18 * root.s
                                        anchors.right: noteX.left
                                        anchors.rightMargin: 8 * root.s
                                        spacing: 2 * root.s

                                        Text {
                                            text: noteItem.modelData.entry
                                                ? Qt.formatDateTime(noteItem.modelData.entry, "ddd d MMM  ·  HH:mm") : ""
                                            color: Theme.textFaint
                                            font.family: Theme.font
                                            font.pixelSize: 9.5 * root.s
                                            font.features: { "tnum": 1 }
                                        }
                                        Text {
                                            width: parent.width
                                            text: noteItem.modelData.text
                                            color: Theme.textSubtle
                                            font.family: Theme.font
                                            font.pixelSize: 11.5 * root.s
                                            wrapMode: Text.Wrap
                                            textFormat: Text.PlainText
                                            lineHeight: 1.15
                                        }
                                    }

                                    Icon {
                                        id: noteX
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        size: 11 * root.s
                                        text: Icons.close
                                        opacity: noteHover.hovered ? 1 : 0
                                        color: noteXArea.containsMouse ? Theme.accent : Theme.textDim
                                        Behavior on opacity { NumberAnimation { duration: Motion.fast } }

                                        MouseArea {
                                            id: noteXArea
                                            anchors.fill: parent
                                            anchors.margins: -5 * root.s
                                            enabled: noteHover.hovered
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: { Taskwarrior.denotate(right.t, noteItem.modelData); root.focusField(); }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Flow {
                    id: actions
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    spacing: 6 * root.s

                    ActionButton {
                        icon: right.isDone ? Icons.undo : Icons.check
                        label: right.isDone ? "Reopen" : "Done"
                        keys: "Ctrl+D"
                        onTriggered: { Taskwarrior.toggleDone(right.t); root.focusField(); }
                    }
                    ActionButton {
                        visible: !right.isDone
                        icon: right.t && right.t.start ? Icons.pause : Icons.play
                        label: right.t && right.t.start ? "Stop" : "Start"
                        keys: "Ctrl+S"
                        hot: right.t !== null && right.t.start !== null
                        onTriggered: { Taskwarrior.toggleStart(right.t); root.focusField(); }
                    }
                    ActionButton {
                        icon: Icons.pencil
                        label: "Edit"
                        keys: "Ctrl+E"
                        onTriggered: root.edit("rename")
                    }
                    ActionButton {
                        visible: !right.isDone
                        icon: Icons.sliders
                        label: "Modify"
                        keys: "Ctrl+M"
                        onTriggered: root.edit("modify")
                    }
                    ActionButton {
                        icon: Icons.notePencil
                        label: "Note"
                        keys: "Ctrl+N"
                        onTriggered: root.edit("note")
                    }
                    ActionButton {
                        icon: Icons.trash
                        label: "Delete"
                        keys: "hold to delete  ·  Ctrl+X"
                        hold: true
                        onTriggered: { Taskwarrior.remove(right.t); root.focusField(); }
                    }
                }
            }

            // ─── no task: quick syntax ───────────────────────────────────
            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: right.t === null
                spacing: 14 * root.s

                Column {
                    spacing: 4 * root.s
                    Label { text: root.selRow && root.selRow.kind === "add" ? "New task" : "Quick add" }
                    Text {
                        text: root.selRow && root.selRow.kind === "add" ? "Press Enter to add it" : "Type in the field above"
                        color: Theme.textBright
                        font.family: Theme.font
                        font.pixelSize: 17 * root.s
                        font.weight: Font.DemiBold
                    }
                }

                Column {
                    width: parent.width
                    spacing: 8 * root.s

                    Repeater {
                        model: [
                            ["due:fri", "due date: today, tomorrow, mon, eom, 2026-11-02"],
                            ["+work", "add a tag; -work removes it when modifying"],
                            ["project:infra", "group it under a project"],
                            ["pri:H", "priority: H, M or L"],
                            ["recur:weekly", "repeat it (needs a due date)"],
                            ["wait:mon", "hide it until that day"]
                        ]

                        Row {
                            id: hint
                            required property var modelData
                            spacing: 12 * root.s

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 104 * root.s
                                height: 22 * root.s
                                radius: 7 * root.s
                                color: Theme.frameBg
                                border.width: 1
                                border.color: Theme.frameBorder

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 9 * root.s
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: hint.modelData[0]
                                    color: Theme.accent
                                    font.family: "monospace"
                                    font.pixelSize: 10.5 * root.s
                                    font.weight: Font.DemiBold
                                }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: hint.modelData[1]
                                color: Theme.textSubtle
                                font.family: Theme.font
                                font.pixelSize: 11 * root.s
                            }
                        }
                    }
                }

                /** Key reference: chips that wrap as whole pairs. */
                Flow {
                    width: parent.width
                    spacing: 10 * root.s

                    Repeater {
                        model: [
                            ["↑↓", "select"], ["↵", "add / tick"], ["←→ ^H ^L", "filter"], ["^D", "done"],
                            ["^S", "start"], ["^E", "edit"], ["^M", "modify"], ["^N", "note"],
                            ["^X", "delete"], ["^Z", "undo"]
                        ]

                        Row {
                            id: keyHint
                            required property var modelData
                            spacing: 4 * root.s

                            Text {
                                text: keyHint.modelData[0]
                                color: Theme.textSubtle
                                font.family: Theme.font
                                font.pixelSize: 10 * root.s
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: keyHint.modelData[1]
                                color: Theme.textFaint
                                font.family: Theme.font
                                font.pixelSize: 10 * root.s
                            }
                        }
                    }
                }
            }
        }
    }
}
