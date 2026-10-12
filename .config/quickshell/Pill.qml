pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import "services"
import "widgets"
import "surfaces"

/**
 * The pill body. One element carries every state. Width/height driven by `mode`
 * (rest, osd, toast, or an open surface) with a no-overshoot easing so surfaces
 * grow out of the pill in place. Surfaces are stacked absolutely and cross-fade.
 *
 * The rest pill is a three-part bar: workspace dots on the left, CPU % and
 * used RAM dead centre, the clock on the right. Surfaces only open via IPC.
 */
Item {
    id: pill

    property real s: 1
    property string surface: ""

    readonly property bool surfaceOpen: surface.length > 0

    readonly property bool toastActive: Notifs.popups.length > 0
    readonly property bool osdActive: osd.flashing

    readonly property real restCorner: 18 * s
    readonly property real openCorner: 22 * s

    // ─── Size constants ───────────────────────────────────────────────────────
    readonly property real restH: 38 * s
    readonly property real restPad: 22 * s
    readonly property real restGap: 22 * s
    /** Side columns share one width so the stats stay dead centre. */
    readonly property real restSideW: Math.max(ws.implicitWidth, restClock.implicitWidth)
    readonly property real restW: 2 * restSideW + stats.implicitWidth + 2 * restGap + 2 * restPad
    readonly property real toastW: 342 * s

    /**
     * Single source of truth for every morphing surface, keyed by its `surface`
     * string. Each entry is a thunk so the geometry it reads registers as a
     * live dep of targetSize.
     */
    readonly property var surfaces: ({
        launcher:      () => Qt.size(360 * s, 332 * s),
        clipboard:     () => Qt.size(360 * s, 332 * s),
        themes:        () => Qt.size(400 * s, 360 * s),
        wallpaper:     () => Qt.size(720 * s, 172 * s),
        power:         () => Qt.size(330 * s, 150 * s),
        web:           () => Qt.size(400 * s, web.implicitHeight + 29 * s),
        notifications: () => Qt.size(330 * s, notifications.implicitHeight + 26 * s)
    })

    readonly property string mode: surfaceOpen && surfaces[surface] !== undefined ? surface
        : (osdActive ? "osd"
        : (toastActive ? "toast" : "rest"))

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
        osd:   () => Qt.size(osd.desiredW, osd.desiredH),
        toast: () => Qt.size(toastW, toastLoader.item ? toastLoader.item.implicitHeight + 24 * s : restH)
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

    Behavior on width { NumberAnimation { duration: Motion.morph; easing.type: Motion.easeMorph; easing.bezierCurve: Motion.morphCurve } }
    Behavior on height { NumberAnimation { duration: Motion.morph; easing.type: Motion.easeMorph; easing.bezierCurve: Motion.morphCurve } }
    Behavior on morphRadius { NumberAnimation { duration: Motion.morph; easing.type: Motion.easeMorph; easing.bezierCurve: Motion.morphCurve } }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: pill.morphRadius
        border.width: 1
        border.color: Theme.border
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.alpha(Theme.cardTop, Flags.pillOpacity) }
            GradientStop { position: 1.0; color: Qt.alpha(Theme.cardBot, Flags.pillOpacity) }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.shadow
            shadowBlur: 0.7
            shadowVerticalOffset: 3 * pill.s
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: body.radius * 0.6
            anchors.rightMargin: body.radius * 0.6
            height: 1
            color: Theme.sheen
        }
    }

    /** One CPU/RAM readout: dim glyph, tabular value; turns hot when `hot`. */
    component Stat: Row {
        id: stat
        property string icon: ""
        property string text: ""
        property bool hot: false

        spacing: 5 * pill.s

        GlyphIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 15 * pill.s
            height: 15 * pill.s
            name: stat.icon
            color: stat.hot ? Theme.accent : Theme.icon
            stroke: 1.7
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
                icon: "cpu"
                text: Sysmon.cpu + "%"
                hot: Sysmon.cpu >= 90
            }
            Stat {
                anchors.verticalCenter: parent.verticalCenter
                icon: "memory"
                text: Sysmon.memUsedGb.toFixed(1) + "G"
                hot: Sysmon.memPct >= 90
            }
        }

        Text {
            id: restClock
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: clock.hhmm
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 16 * pill.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
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

    Osd {
        id: osd
        anchors.fill: parent
        anchors.topMargin: 12 * pill.s
        anchors.leftMargin: 18 * pill.s
        anchors.rightMargin: 18 * pill.s
        anchors.bottomMargin: 12 * pill.s
        s: pill.s
        suppressed: pill.surfaceOpen
        enabled: pill.mode === "osd"
        opacity: pill.mode === "osd" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity {
            NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard }
        }
    }

    Loader {
        id: toastLoader
        active: pill.toastActive
        anchors.fill: parent
        anchors.topMargin: 12 * pill.s
        anchors.leftMargin: 16 * pill.s
        anchors.rightMargin: 16 * pill.s
        anchors.bottomMargin: 12 * pill.s
        enabled: pill.mode === "toast"
        opacity: pill.mode === "toast" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity {
            NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard }
        }

        sourceComponent: Item {
            implicitHeight: toastContent.implicitHeight

            Toast {
                id: toastContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                s: pill.s
                live: pill.mode === "toast"
                notif: Notifs.popups.length > 0 ? Notifs.popups[Notifs.popups.length - 1] : null
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                visible: Notifs.popups.length > 1
                text: "+" + (Notifs.popups.length - 1)
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: 9 * pill.s
                font.weight: Font.DemiBold
            }
        }
    }
}
