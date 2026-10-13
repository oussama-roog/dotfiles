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
 * The rest pill is symmetric: the clock dead centre, CPU % on the left and used
 * RAM on the right, mirrored so their icons sit on the outer edges and the
 * values face the clock. Surfaces only open via IPC.
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

    readonly property real restCorner: 18 * s
    readonly property real openCorner: 24 * s

    // ─── Size constants ───────────────────────────────────────────────────────
    readonly property real restH: 38 * s
    readonly property real restPad: 20 * s
    readonly property real restGap: 18 * s
    readonly property real statIconSize: 15 * s
    readonly property real statSpacing: 6 * s
    /**
     * Both stat slots are sized for their widest value, so the clock stays dead
     * centre and the notch doesn't twitch as the numbers change.
     */
    readonly property real restSideW: statIconSize + statSpacing
        + Math.max(widestCpu.advanceWidth, widestRam.advanceWidth)
    readonly property real restW: 2 * restSideW + restClock.implicitWidth + 2 * restGap + 2 * restPad
    /** Shared width of the list surfaces (launcher, clipboard, web, themes, notifications, agents). */
    readonly property real listW: 460 * s

    /**
     * Single source of truth for every morphing surface, keyed by its `surface`
     * string. Each entry is a thunk so the geometry it reads registers as a
     * live dep of targetSize.
     */
    readonly property var surfaces: ({
        launcher:      () => Qt.size(listW, 332 * s),
        clipboard:     () => Qt.size(860 * s, 420 * s),
        themes:        () => Qt.size(listW, 360 * s),
        wallpaper:     () => Qt.size(1000 * s, 222 * s),
        power:         () => Qt.size(340 * s, 106 * s),
        web:           () => Qt.size(listW, web.implicitHeight + 29 * s),
        notifications: () => Qt.size(listW, notifications.implicitHeight + 26 * s),
        agents:        () => Qt.size(listW, agents.implicitHeight + 26 * s),
        tasks:         () => Qt.size(920 * s, 540 * s)
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

    /** A task is started: a thin accent bar along the bottom of the resting notch. */
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.8
        height: 2.5 * pill.s
        radius: height / 2
        color: Theme.accent
        opacity: Taskwarrior.working && pill.mode === "rest" ? Math.pow(pill.morphCloseness, 1.5) : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
    }

    TextMetrics { id: widestCpu; font: statFont.font; text: "100%" }
    TextMetrics { id: widestRam; font: statFont.font; text: "88.8G" }
    Text {
        id: statFont
        visible: false
        font.family: Theme.font
        font.pixelSize: 13 * pill.s
        font.weight: Font.DemiBold
        font.features: { "tnum": 1 }
    }

    /**
     * One CPU/RAM readout: dim glyph, tabular value; turns hot when `hot`.
     * `mirrored` puts the glyph on the right, for the right-hand slot.
     */
    component Stat: Row {
        id: stat
        property string icon: ""
        property string text: ""
        property bool hot: false
        property bool mirrored: false

        spacing: pill.statSpacing
        layoutDirection: mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            size: pill.statIconSize
            text: stat.icon
            color: stat.hot ? Theme.accent : Theme.icon
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: stat.text
            color: stat.hot ? Theme.accent : Theme.text
            font: statFont.font
            Behavior on color { ColorAnimation { duration: Motion.standard } }
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

        Stat {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: Icons.cpu
            text: Sysmon.cpu + "%"
            hot: Sysmon.cpu >= 90
        }

        Text {
            id: restClock
            anchors.centerIn: parent
            text: clock.hhmm
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 16 * pill.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
        }

        Stat {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            mirrored: true
            icon: Icons.ram
            text: Sysmon.memUsedGb.toFixed(1) + "G"
            hot: Sysmon.memPct >= 90
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
    Agents        { id: agents; host: pill; name: "agents" }
    Tasks         { host: pill; name: "tasks" }

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
