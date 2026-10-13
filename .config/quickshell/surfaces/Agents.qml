pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import "../services"
import "../widgets"

/**
 * Agents centre, opened from the left dot (or `qs ipc call pill agents`).
 * Top to bottom:
 *
 *   now playing   cover, title, artist and a live progress bar; no buttons,
 *                 the media keys drive playback. Hidden when nothing plays.
 *   agent tabs    one per agent in AgentHub (Claude, Antigravity), each with
 *                 a mark when it waits on you or works; the rest below is the
 *                 selected agent's.
 *   plan usage    the agent's plan limits with their reset countdowns, as its
 *                 status line last reported them.
 *   sessions      every session its hooks have seen: status, context tokens,
 *                 age and what it is doing or last said.
 *
 * Left/Right, h/l or Ctrl+H/Ctrl+L switch agent (Tab too); Up/Down, j/k or
 * Ctrl+J/Ctrl+K pick a session, Enter jumps to its terminal, x or Delete drops
 * it from the list. It opens on the agent that needs you, else one that works,
 * else the one you last looked at.
 */
PillSurface {
    id: root

    mTop: 13
    mLeft: 16
    mRight: 16
    mBottom: 13

    implicitHeight: mainCol.implicitHeight

    readonly property var sources: AgentHub.sources
    property int tab: 0
    readonly property var src: sources[Math.min(tab, sources.length - 1)]

    property int index: 0
    readonly property var list: src.sessions
    onListChanged: index = Math.max(0, Math.min(index, list.length - 1))

    /** The agent that needs you, else one that works, else the current tab. */
    function busiestTab() {
        for (var i = 0; i < sources.length; i++)
            if (sources[i].needsYou)
                return i;
        if (!sources[tab].running)
            for (var j = 0; j < sources.length; j++)
                if (sources[j].working > 0)
                    return j;
        return tab;
    }

    onOpenChanged: {
        if (open) {
            tab = busiestTab();
            index = 0;
            Qt.callLater(root.forceActiveFocus);
        }
    }

    function move(dir) {
        if (list.length > 0)
            index = Math.max(0, Math.min(list.length - 1, index + dir));
    }

    /** Next or previous agent, wrapping round. */
    function switchTab(dir) {
        tab = (tab + dir + sources.length) % sources.length;
        index = 0;
    }

    function jump() {
        if (index < list.length) {
            AgentHub.focus(list[index]);
            root.requestClose();
        }
    }

    Keys.onUpPressed: move(-1)
    Keys.onDownPressed: move(1)
    Keys.onLeftPressed: switchTab(-1)
    Keys.onRightPressed: switchTab(1)
    Keys.onTabPressed: switchTab(1)
    Keys.onBacktabPressed: switchTab(-1)
    Keys.onReturnPressed: jump()
    Keys.onEnterPressed: jump()
    Keys.onDeletePressed: if (index < list.length) AgentHub.forget(list[index])
    Keys.onPressed: (e) => {
        if (e.key === Qt.Key_J || e.key === Qt.Key_K) {
            move(e.key === Qt.Key_J ? 1 : -1);
            e.accepted = true;
        } else if (e.key === Qt.Key_H || e.key === Qt.Key_L) {
            switchTab(e.key === Qt.Key_L ? 1 : -1);
            e.accepted = true;
        } else if (e.key === Qt.Key_X && index < list.length) {
            AgentHub.forget(list[index]);
            e.accepted = true;
        }
    }

    /** Small caps section label, the inbox header's style. */
    component Label: Text {
        color: Theme.textSubtle
        font.family: Theme.font
        font.pixelSize: 9.5 * root.s
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1.5 * root.s
    }

    /** Small tabular figure on a session's bottom line. */
    component Meta: Text {
        color: Theme.textDim
        font.family: Theme.font
        font.pixelSize: 9 * root.s
        font.features: { "tnum": 1 }
    }

    component Hair: Rectangle {
        width: parent ? parent.width : 0
        height: 1
        color: Theme.hair
    }

    /** Thin track with an accent fill; `hot` past 80%. */
    component Bar: Rectangle {
        id: bar
        property real value: 0
        property bool hot: value >= 0.8

        height: 4 * root.s
        radius: height / 2
        color: Theme.hair

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(bar.value > 0 ? parent.height : 0, parent.width * Math.min(1, bar.value))
            radius: parent.radius
            color: bar.hot ? Theme.accent : Theme.accentDark
            Behavior on width { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
        }
    }

    /** One plan window: name, bar, percentage, reset countdown. */
    component UsageRow: Item {
        id: urow
        property string label: ""
        property var win: null

        width: parent ? parent.width : 0
        height: 18 * root.s

        Text {
            id: ulabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 62 * root.s
            text: urow.label
            color: Theme.textSubtle
            font.family: Theme.font
            font.pixelSize: 10.5 * root.s
            font.weight: Font.Medium
        }

        Text {
            id: ureset
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 62 * root.s
            horizontalAlignment: Text.AlignRight
            text: !urow.win ? "" : urow.win.resetsAt > 0 ? "↻ " + AgentHub.span(urow.win.resetsAt - AgentHub.now) : "reset"
            color: Theme.textFaint
            font.family: Theme.font
            font.pixelSize: 9.5 * root.s
            font.features: { "tnum": 1 }
        }

        Text {
            id: upct
            anchors.right: ureset.left
            anchors.rightMargin: 8 * root.s
            anchors.verticalCenter: parent.verticalCenter
            width: 32 * root.s
            horizontalAlignment: Text.AlignRight
            text: urow.win ? Math.round(urow.win.pct) + "%" : "—"
            color: urow.win && urow.win.pct >= 80 ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: 10.5 * root.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
        }

        Bar {
            anchors.left: ulabel.right
            anchors.right: upct.left
            anchors.rightMargin: 10 * root.s
            anchors.verticalCenter: parent.verticalCenter
            value: urow.win ? urow.win.pct / 100 : 0
        }
    }

    /**
     * One session, three lines so nothing crowds:
     *   title (generated or /rename)                         [status]
     *   what it is doing, or what it last said
     *   folder · tmux spot                 ctx % · out · +/− · age
     */
    component SessionRow: Item {
        id: srow
        required property var modelData
        required property int index
        readonly property var ss: modelData
        readonly property bool selected: root.index === index
        readonly property bool hot: ss.status === "waiting" || ss.status === "question"
        readonly property bool live: hot || ss.status === "working"
        readonly property real inset: 10 * root.s
        readonly property real textLeft: inset + 16 * root.s + 10 * root.s

        width: parent ? parent.width : 0
        height: sessionList.rowH

        /** The selection itself is the sliding accent highlight under the list. */
        Rectangle {
            anchors.fill: parent
            radius: 10 * root.s
            color: !srow.selected && rowHover.hovered ? Qt.alpha(Theme.text, 0.03) : "transparent"
            Behavior on color { ColorAnimation { duration: Motion.fast } }
        }

        HoverHandler { id: rowHover }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { root.index = srow.index; root.jump(); }
        }

        /** Status mark, level with the title: spins while working, pulses when it needs you. */
        Item {
            id: mark
            x: srow.inset
            anchors.verticalCenter: titleText.verticalCenter
            width: 16 * root.s
            height: 16 * root.s

            /** On the accent highlight the agent's colour gets a disc to stand on. */
            Rectangle {
                anchors.centerIn: parent
                visible: srow.ss.status === "working" && srow.selected
                width: 20 * root.s
                height: width
                radius: width / 2
                color: Theme.onAccent
            }
            AgentRing {
                anchors.centerIn: parent
                size: 15 * root.s
                thickness: 2 * root.s
                visible: srow.ss.status === "working"
                spinning: visible && root.open
                colors: [AgentHub.source(srow.ss.agent).color]
            }
            Icon {
                anchors.centerIn: parent
                size: 15 * root.s
                visible: srow.ss.status !== "working"
                text: srow.ss.status === "waiting" ? Icons.warning
                    : srow.ss.status === "question" ? Icons.question
                    : srow.ss.status === "done" ? Icons.checkCircle
                    : Icons.terminal
                color: srow.selected ? Theme.onAccent : srow.hot ? Theme.accent : Theme.textSubtle
                SequentialAnimation on opacity {
                    running: srow.hot && root.open
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.45; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.45; to: 1; duration: 800; easing.type: Easing.InOutSine }
                }
            }
        }

        // ── Line 1: title + status chip ──
        Rectangle {
            id: chip
            anchors.right: parent.right
            anchors.rightMargin: srow.inset
            anchors.verticalCenter: titleText.verticalCenter
            width: chipText.implicitWidth + 12 * root.s
            height: 16 * root.s
            radius: height / 2
            color: srow.selected ? Qt.alpha(Theme.onAccent, 0.14) : srow.hot ? Qt.alpha(Theme.accent, 0.16) : Theme.frameBg
            border.width: 1
            border.color: srow.selected ? Qt.alpha(Theme.onAccent, 0.35) : srow.hot ? Qt.alpha(Theme.accent, 0.45) : Theme.frameBorder

            Text {
                id: chipText
                anchors.centerIn: parent
                text: AgentHub.statusLabel(srow.ss) + (srow.ss.agents > 0 ? " · " + srow.ss.agents + " sub" : "")
                color: srow.selected ? Theme.onAccent : srow.hot ? Theme.accent : srow.live ? Theme.text : Theme.textDim
                font.family: Theme.font
                font.pixelSize: 9 * root.s
                font.weight: Font.DemiBold
            }
        }

        Text {
            id: titleText
            x: srow.textLeft
            y: 7 * root.s
            width: chip.x - x - 10 * root.s
            text: AgentHub.title(srow.ss)
            color: srow.selected ? Theme.onAccent : Theme.textBright
            font.family: Theme.font
            font.pixelSize: 11.5 * root.s
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
        }

        // ── Line 2: what it is doing / last said ──
        Text {
            x: srow.textLeft
            anchors.top: titleText.bottom
            anchors.topMargin: 4 * root.s
            width: parent.width - x - srow.inset
            readonly property bool tool: srow.live && /^(Bash|Edit|Write|Read|Grep|Glob|MultiEdit|Fetch|Search|MCP|Agent) /.test(text)
            text: AgentHub.detail(srow.ss) || "—"
            color: srow.selected ? Qt.alpha(Theme.onAccent, 0.85) : srow.hot ? Theme.text : Theme.textSubtle
            font.family: tool ? "monospace" : Theme.font
            font.pixelSize: (tool ? 9.5 : 10.5) * root.s
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
        }

        // ── Line 3: where it runs + numbers ──
        Row {
            id: meta
            anchors.right: parent.right
            anchors.rightMargin: srow.inset
            anchors.verticalCenter: placeText.verticalCenter
            spacing: 10 * root.s

            Meta {
                visible: (srow.ss.ctx || 0) > 0
                text: "ctx " + (typeof srow.ss.ctxPct === "number" ? Math.round(srow.ss.ctxPct) + "% · " : "") + AgentHub.tokens(srow.ss.ctx)
                color: srow.selected ? Qt.alpha(Theme.onAccent, 0.7) : (srow.ss.ctxPct || 0) >= 80 ? Theme.accent : Theme.textDim
            }
            Meta {
                visible: (srow.ss.out || 0) > 0
                text: AgentHub.tokens(srow.ss.out) + " out"
                color: srow.selected ? Qt.alpha(Theme.onAccent, 0.7) : Theme.textDim
            }
            Meta {
                visible: (srow.ss.added || 0) + (srow.ss.removed || 0) > 0
                text: "+" + (srow.ss.added || 0) + " −" + (srow.ss.removed || 0)
                color: srow.selected ? Qt.alpha(Theme.onAccent, 0.7) : Theme.textDim
            }
            Meta {
                /** Running sessions count up from their start; the rest show how long ago. */
                text: srow.live ? AgentHub.span(AgentHub.now - (srow.ss.started || AgentHub.now))
                    : AgentHub.span(AgentHub.now - (srow.ss.updated || AgentHub.now)) + " ago"
                color: srow.selected ? Qt.alpha(Theme.onAccent, 0.6) : Theme.textFaint
            }
        }

        Text {
            id: placeText
            x: srow.textLeft
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 7 * root.s
            width: Math.max(0, meta.x - x - 12 * root.s)
            text: AgentHub.place(srow.ss)
            color: srow.selected ? Qt.alpha(Theme.onAccent, 0.6) : Theme.textFaint
            font.family: Theme.font
            font.pixelSize: 9 * root.s
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    Column {
        id: mainCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8 * root.s

        // ─── Header ──────────────────────────────────────────────────────────
        Item {
            width: parent.width
            height: 24 * root.s

            /** The agents dot docks its sparkle here (see shell.qml). */
            readonly property real dotSlot: 24 * root.s

            Row {
                anchors.left: parent.left
                anchors.leftMargin: parent.dotSlot + 6 * root.s
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8 * root.s

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Flags.showGlyphs
                    text: "代"
                    color: Theme.text
                    font.family: Theme.fontJp
                    font.weight: Font.Medium
                    font.pixelSize: 16 * root.s
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Agents"
                }
            }

            Label {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: AgentHub.needsYou ? AgentHub.attention.length + " waiting"
                    : AgentHub.running > 0 ? AgentHub.running + " running"
                    : "idle"
                color: AgentHub.needsYou ? Theme.accent : Theme.textDim
                font.pixelSize: 9 * root.s
                font.weight: Font.Bold
            }
        }

        Hair {}

        // ─── Now playing ─────────────────────────────────────────────────────
        Item {
            id: media
            readonly property var p: Players.active
            readonly property bool has: p !== null && !!p.trackTitle
            readonly property real len: has && p.lengthSupported ? p.length : 0
            readonly property real pos: has && p.positionSupported ? p.position : 0
            readonly property string art: {
                if (!has)
                    return "";
                var u = Players.artUrlFor(p);
                return u && u.indexOf("file:") === 0 ? u + "#" + Players.keyFor(p) : (u || "");
            }

            function clock(sec) {
                sec = Math.max(0, Math.floor(sec));
                var m = Math.floor(sec / 60), ss = sec % 60;
                return m + ":" + (ss < 10 ? "0" : "") + ss;
            }

            visible: has
            width: parent.width
            height: visible ? 50 * root.s : 0

            /** MPRIS only pushes position on seeks; poll it while visible. */
            Timer {
                interval: 500
                repeat: true
                running: root.open && media.has && media.p.isPlaying
                onTriggered: media.p.positionChanged()
            }

            ClippingRectangle {
                id: cover
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 46 * root.s
                height: 46 * root.s
                radius: 10 * root.s
                color: Theme.tileBg

                Image {
                    id: coverImg
                    anchors.fill: parent
                    source: media.art
                    sourceSize: Qt.size(Math.ceil(width * 2), Math.ceil(height * 2))
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: String(source).indexOf("file:") !== 0
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: Motion.standard } }
                }
                Icon {
                    anchors.centerIn: parent
                    size: parent.width * 0.42
                    text: Icons.music
                    color: Theme.textSubtle
                    visible: coverImg.status !== Image.Ready
                }
            }

            Column {
                anchors.left: cover.right
                anchors.leftMargin: 12 * root.s
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3 * root.s

                Row {
                    width: parent.width
                    spacing: 6 * root.s

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 10 * root.s
                        text: media.has && media.p.isPlaying ? Icons.play : Icons.pause
                        color: media.has && media.p.isPlaying ? Theme.accent : Theme.textDim
                    }
                    Text {
                        width: parent.width - 16 * root.s
                        text: media.has ? media.p.trackTitle : ""
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 12 * root.s
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                }

                Text {
                    width: parent.width
                    text: media.has ? Players.artistsOf(media.p.trackArtists, media.p.trackArtist) : ""
                    visible: text.length > 0
                    color: Theme.textSubtle
                    font.family: Theme.font
                    font.pixelSize: 10.5 * root.s
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }

                Item {
                    width: parent.width
                    height: 12 * root.s
                    visible: media.len > 0

                    Text {
                        id: tPos
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: media.clock(media.pos)
                        color: Theme.textFaint
                        font.family: Theme.font
                        font.pixelSize: 9 * root.s
                        font.features: { "tnum": 1 }
                    }
                    Text {
                        id: tLen
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: media.clock(media.len)
                        color: Theme.textFaint
                        font.family: Theme.font
                        font.pixelSize: 9 * root.s
                        font.features: { "tnum": 1 }
                    }
                    Bar {
                        anchors.left: tPos.right
                        anchors.leftMargin: 8 * root.s
                        anchors.right: tLen.left
                        anchors.rightMargin: 8 * root.s
                        anchors.verticalCenter: parent.verticalCenter
                        height: 3 * root.s
                        hot: true
                        value: media.len > 0 ? media.pos / media.len : 0
                    }
                }
            }
        }

        Hair { visible: media.has }

        // ─── Agent tabs ──────────────────────────────────────────────────────
        Item {
            id: tabs
            width: parent.width
            height: 28 * root.s

            readonly property real gap: 4 * root.s
            readonly property real tabW: (width - 2 * gap - (root.sources.length - 1) * gap) / root.sources.length

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Theme.frameBg
                border.width: 1
                border.color: Theme.frameBorder
            }

            ElasticHighlight {
                tx: tabs.gap + root.tab * (tabs.tabW + tabs.gap)
                ty: tabs.gap
                tw: tabs.tabW
                th: tabs.height - 2 * tabs.gap
                radius: 14 * root.s
            }

            Repeater {
                model: root.sources

                Item {
                    id: tabItem
                    required property var modelData
                    required property int index
                    readonly property var src: modelData
                    readonly property bool selected: root.tab === index

                    x: tabs.gap + index * (tabs.tabW + tabs.gap)
                    y: tabs.gap
                    width: tabs.tabW
                    height: tabs.height - 2 * tabs.gap

                    Row {
                        anchors.centerIn: parent
                        spacing: 6 * root.s

                        /** Waiting on you: pulsing dot; working: spinner; else nothing. */
                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: tabItem.src.running > 0
                            width: 10 * root.s
                            height: 10 * root.s

                            Rectangle {
                                anchors.centerIn: parent
                                visible: tabItem.src.needsYou
                                width: 7 * root.s
                                height: width
                                radius: width / 2
                                color: tabItem.selected ? Theme.onAccent : Theme.accent
                                SequentialAnimation on opacity {
                                    running: tabItem.src.needsYou && root.open
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1; to: 0.35; duration: 800; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 0.35; to: 1; duration: 800; easing.type: Easing.InOutSine }
                                }
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                visible: !tabItem.src.needsYou && tabItem.selected
                                width: 14 * root.s
                                height: width
                                radius: width / 2
                                color: Theme.onAccent
                            }
                            AgentRing {
                                anchors.centerIn: parent
                                visible: !tabItem.src.needsYou
                                size: 10 * root.s
                                thickness: 1.6 * root.s
                                colors: [tabItem.src.color]
                                spinning: visible && tabItem.src.working > 0 && root.open
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: tabItem.src.label
                            color: tabItem.selected ? Theme.onAccent : tabHover.hovered ? Theme.text : Theme.textSubtle
                            font.family: Theme.font
                            font.pixelSize: 11 * root.s
                            font.weight: Font.DemiBold
                            Behavior on color { ColorAnimation { duration: Motion.fast } }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: tabItem.src.sessions.length > 0
                            text: tabItem.src.sessions.length
                            color: tabItem.selected ? Qt.alpha(Theme.onAccent, 0.75) : Theme.textFaint
                            font.family: Theme.font
                            font.pixelSize: 9.5 * root.s
                            font.weight: Font.DemiBold
                            font.features: { "tnum": 1 }
                        }
                    }

                    HoverHandler { id: tabHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.tab = tabItem.index; root.index = 0; }
                    }
                }
            }
        }

        // ─── Plan usage ──────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: 4 * root.s

            Item {
                width: parent.width
                height: 14 * root.s

                Label {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Plan usage" + (root.src.usage.plan ? "  ·  " + root.src.usage.plan : "")
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    readonly property double age: AgentHub.now - (root.src.usage.updated || 0)
                    visible: root.src.hasUsage
                    text: age < 90000 ? "live" : "updated " + AgentHub.span(age) + " ago"
                    color: age < 90000 ? Theme.accentDim : Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 9 * root.s
                }
            }

            Repeater {
                model: root.src.plan
                UsageRow {
                    required property var modelData
                    label: modelData.label
                    win: modelData
                }
            }

            Text {
                visible: !root.src.hasUsage
                width: parent.width
                text: root.src.usageHint
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: 10 * root.s
                wrapMode: Text.WordWrap
            }
        }

        Hair {}

        // ─── Sessions ────────────────────────────────────────────────────────
        Item {
            width: parent.width
            height: 14 * root.s

            Label {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Sessions"
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.list.length > 0
                text: "↵ jump   x forget   ←→ agent"
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: 9 * root.s
            }
        }

        ListView {
            id: sessionList
            readonly property real rowH: 62 * root.s
            width: parent.width
            height: root.list.length === 0 ? 0 : Math.min(root.list.length, 3) * rowH + (Math.min(root.list.length, 3) - 1) * spacing
            spacing: 4 * root.s
            clip: true
            interactive: root.list.length > 3
            boundsBehavior: Flickable.StopAtBounds
            model: root.list
            currentIndex: root.index
            highlightFollowsCurrentItem: false
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            ElasticHighlight {
                parent: sessionList.contentItem
                z: -1
                tx: 0
                ty: root.index * (sessionList.rowH + sessionList.spacing)
                tw: sessionList.width
                th: sessionList.rowH
                radius: 10 * root.s
                shown: root.list.length > 0
            }

            delegate: SessionRow {}
        }

        Text {
            visible: root.list.length === 0
            width: parent.width
            text: "No " + root.src.label + " sessions. Start one with " + root.src.command + " in a terminal."
            color: Theme.textFaint
            font.family: Theme.font
            font.pixelSize: 10 * root.s
            wrapMode: Text.WordWrap
        }
    }
}
