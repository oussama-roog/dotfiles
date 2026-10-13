pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "services"
import "widgets"
import "surfaces"

/**
 * The pill body. One element carries every state. Width/height driven by `mode`
 * (rest, osd, or an open surface) with a no-overshoot easing so surfaces
 * grow out of the pill in place. Surfaces are stacked absolutely and cross-fade.
 *
 * The rest pill is a three-part bar: workspace dots on the left, CPU % and
 * used RAM dead centre, the clock on the right. Hovering it (`peek`) widens it
 * in place, same height, to add volume and battery to the stats and the date
 * before the clock. Surfaces only open via IPC.
 *
 * Drawn as an Ambxst-style notch hanging from the top edge, with concave
 * "ears" joining it to the screen.
 */
Item {
    id: pill

    property real s: 1
    property string surface: ""

    readonly property bool surfaceOpen: surface.length > 0

    readonly property bool osdActive: osd.flashing

    /**
     * Hover peek: on after a short hover so passing the cursor across the top
     * edge doesn't flicker it, off a beat after leaving.
     */
    property bool peek: false
    HoverHandler { id: restHover }
    Timer {
        interval: restHover.hovered ? 150 : 250
        running: (restHover.hovered && pill.mode === "rest") !== pill.peek
        onTriggered: pill.peek = restHover.hovered && pill.mode === "rest"
    }
    onModeChanged: if (mode !== "rest") peek = false

    readonly property real restCorner: 18 * s
    readonly property real openCorner: 24 * s

    // ─── Size constants ───────────────────────────────────────────────────────
    readonly property real restH: 38 * s
    readonly property real restPad: 22 * s
    readonly property real restGap: 22 * s
    /** Side columns share one width so the stats stay dead centre. */
    readonly property real restSideW: Math.max(ws.implicitWidth, clockRow.implicitWidth)
    readonly property real restW: 2 * restSideW + stats.implicitWidth + 2 * restGap + 2 * restPad
    /** Shared width of the list surfaces (launcher, clipboard, web, themes, notifications, claude). */
    readonly property real listW: 460 * s

    /**
     * Single source of truth for every morphing surface, keyed by its `surface`
     * string. Each entry is a thunk so the geometry it reads registers as a
     * live dep of targetSize.
     */
    readonly property var surfaces: ({
        launcher:      () => Qt.size(listW, 332 * s),
        clipboard:     () => Qt.size(listW, 332 * s),
        themes:        () => Qt.size(listW, 360 * s),
        wallpaper:     () => Qt.size(1000 * s, 222 * s),
        power:         () => Qt.size(340 * s, 106 * s),
        web:           () => Qt.size(listW, web.implicitHeight + 29 * s),
        notifications: () => Qt.size(listW, notifications.implicitHeight + 26 * s),
        claude:        () => Qt.size(listW, agents.implicitHeight + 26 * s)
    })

    readonly property string mode: surfaceOpen && surfaces[surface] !== undefined ? surface
        : (osdActive ? "osd" : "rest")

    signal requestClose()

    QtObject {
        id: clock
        readonly property var now: sysClock.date
        readonly property string timeFormat: (Flags.time12h ? "h:mm" : "HH:mm")
            + (Flags.clockSeconds ? ":ss" : "")
            + (Flags.time12h ? " AP" : "")
        readonly property string hhmm: Qt.formatTime(now, timeFormat)
    }

    SystemClock {
        id: sysClock
        precision: Flags.clockSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    property real morphRadius: mode === "rest" ? restCorner : openCorner

    /**
     * Target geometry for the non-surface morph modes. Thunks so the properties
     * they read register as live deps of targetSize.
     */
    readonly property var modeSize: ({
        osd:   () => Qt.size(osd.desiredW, osd.desiredH)
    })

    readonly property size targetSize: {
        const sf = surfaces[mode];
        if (sf)
            return sf();
        const f = modeSize[mode];
        return f ? f() : Qt.size(restW, restH);
    }
    readonly property real targetW: targetSize.width
    readonly property real targetH: targetSize.height

    width: targetW
    height: targetH

    /**
     * How settled the pill is into its target geometry: 0 while the morph is far
     * away, 1 once it arrives. Content opacities key off this, not their own
     * timers, so a surface fades in as the pill reaches full size, never over a
     * half-grown pill.
     */
    readonly property real morphCloseness: {
        const d = Math.max(Math.abs(width - targetW), Math.abs(height - targetH));
        return 1 - Math.min(1, d / (110 * s));
    }

    /** Ambxst motion: grow with a slight overshoot, settle back without one. */
    readonly property bool expanding: mode !== "rest"
    Behavior on width { NumberAnimation { duration: Motion.morph; easing.type: pill.expanding ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }
    Behavior on height { NumberAnimation { duration: Motion.morph; easing.type: pill.expanding ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }
    Behavior on morphRadius { NumberAnimation { duration: Motion.morph; easing.type: Motion.easeClose } }

    NotchBody {
        anchors.fill: parent
        s: pill.s
        radius: pill.morphRadius
    }

    /** One CPU/RAM readout: dim glyph, tabular value; turns hot when `hot`. */
    component Stat: Row {
        id: stat
        property string icon: ""
        property string text: ""
        property bool hot: false
        /** Shown only while peeking. */
        property bool extra: false

        spacing: 5 * pill.s
        visible: !extra || pill.peek
        opacity: !extra || pill.peek ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            size: 15 * pill.s
            text: stat.icon
            color: stat.hot ? Theme.accent : Theme.icon
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: stat.text
            color: stat.hot ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: 13 * pill.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
        }
    }

    Item {
        id: rest
        anchors.fill: parent
        anchors.leftMargin: pill.restPad
        anchors.rightMargin: pill.restPad
        opacity: pill.mode === "rest" ? Math.pow(pill.morphCloseness, 1.5) : 0
        visible: opacity > 0.01
        enabled: pill.mode === "rest"
        Behavior on opacity { NumberAnimation { duration: pill.mode === "rest" ? Motion.fast : 260 } }
        scale: pill.mode === "rest" ? 1 : 0.86
        Behavior on scale { NumberAnimation { duration: Motion.morph; easing.type: pill.mode === "rest" ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }

        Workspaces {
            id: ws
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: implicitWidth
            s: pill.s
            gap: 8 * pill.s
        }

        Row {
            id: stats
            anchors.centerIn: parent
            spacing: 12 * pill.s

            Stat {
                anchors.verticalCenter: parent.verticalCenter
                icon: Icons.cpu
                text: Sysmon.cpu + "%"
                hot: Sysmon.cpu >= 90
            }
            Stat {
                anchors.verticalCenter: parent.verticalCenter
                icon: Icons.ram
                text: Sysmon.memUsedGb.toFixed(1) + "G"
                hot: Sysmon.memPct >= 90
            }
            Stat {
                anchors.verticalCenter: parent.verticalCenter
                extra: true
                icon: osd.muted ? Icons.speakerOff : Icons.speaker
                text: osd.muted ? "mute" : Math.round(osd.volume * 100) + "%"
            }
            Stat {
                anchors.verticalCenter: parent.verticalCenter
                extra: Battery.present
                visible: Battery.present && pill.peek
                icon: Battery.charging ? Icons.lightning : Battery.pct > 60 ? Icons.batteryHigh : Battery.pct > 25 ? Icons.batteryMedium : Icons.batteryLow
                text: Battery.pct + "%"
                hot: Battery.pct <= 15 && !Battery.charging
            }
        }

        Row {
            id: clockRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10 * pill.s

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: pill.peek
                opacity: pill.peek ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
                text: Qt.formatDate(clock.now, "ddd d MMM")
                color: Theme.textSubtle
                font.family: Theme.font
                font.pixelSize: 13 * pill.s
                font.weight: Font.Medium
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: clock.hhmm
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 16 * pill.s
                font.weight: Font.DemiBold
                font.features: { "tnum": 1 }
            }
        }
    }

    // Surfaces: each shows while `surface` equals its name (see PillSurface).
    Launcher      { host: pill; name: "launcher" }
    Clipboard     { host: pill; name: "clipboard" }
    ThemePicker   { host: pill; name: "themes" }
    Wallpaper     { host: pill; name: "wallpaper" }
    Power         { host: pill; name: "power" }
    Web           { id: web; host: pill; name: "web" }
    Notifications { id: notifications; host: pill; name: "notifications" }
    Agents        { id: agents; host: pill; name: "claude" }

    Osd {
        id: osd
        anchors.fill: parent
        anchors.topMargin: 12 * pill.s
        anchors.leftMargin: 18 * pill.s
        anchors.rightMargin: 18 * pill.s
        anchors.bottomMargin: 12 * pill.s
        s: pill.s
        minW: pill.restW
        suppressed: pill.surfaceOpen
        enabled: pill.mode === "osd"
        opacity: pill.mode === "osd" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity {
            NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard }
        }
        scale: pill.mode === "osd" ? 1 : 0.86
        Behavior on scale { NumberAnimation { duration: Motion.morph; easing.type: pill.mode === "osd" ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }
    }
}
