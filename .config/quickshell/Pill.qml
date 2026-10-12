pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import "Singletons"

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
    property string screenName: ""
    property var barWindow
    property string surface: ""

    readonly property bool clipboardOpen: surface === "clipboard"
    readonly property bool wallpaperOpen: surface === "wallpaper"
    readonly property bool powerOpen: surface === "power"
    readonly property bool launcherOpen: surface === "launcher"
    readonly property bool linkOpen: surface === "link"
    readonly property bool webOpen: surface === "web"
    readonly property bool themesOpen: surface === "themes"
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
    readonly property real clipboardW: 360 * s
    readonly property real clipboardH: 332 * s
    readonly property real wallpaperW: 720 * s
    readonly property real wallpaperH: 172 * s
    readonly property real powerW: 330 * s
    readonly property real powerH: 150 * s
    readonly property real launcherW: 360 * s
    readonly property real launcherH: 332 * s
    readonly property real webW: 400 * s
    readonly property real themesW: 400 * s
    readonly property real themesH: 360 * s
    readonly property real toastW: 342 * s

    /**
     * Single source of truth for every morphing surface, keyed by its `surface`
     * string. Each entry is a thunk so the geometry it reads registers as a
     * live dep of targetSize.
     */
    readonly property var surfaces: ({
        launcher:  () => Qt.size(launcherW, launcherH),
        clipboard: () => Qt.size(clipboardW, clipboardH),
        wallpaper: () => Qt.size(wallpaperW, wallpaperH),
        power:     () => Qt.size(powerW, powerH),
        link:      () => Qt.size(link.desiredW, link.implicitHeight + 26 * s),
        web:       () => Qt.size(webW, web.implicitHeight + 29 * s),
        themes:    () => Qt.size(themesW, themesH)
    })

    readonly property string mode: surfaceOpen && surfaces[surface] !== undefined ? surface
        : (osdActive ? "osd"
        : (toastActive ? "toast" : "rest"))

    signal requestSurface(string name)
    signal requestClose()

    /**
     * Pop the open link surface one subview back. Returns true when the step was
     * consumed, false when Escape should close the surface instead.
     */
    function linkBack() {
        return pill.linkOpen ? link.back() : false;
    }

    /** Header bar click: dismiss the open surface back to the rest pill. */
    function surfaceBack() {
        pill.requestClose();
    }

    /**
     * Slide the open wallpaper strip's focus by `dir` thumbs; +1 is right (older)
     * and -1 is left (newer). No-op unless the wallpaper surface is open.
     */
    function wallpaperMove(dir) {
        if (pill.wallpaperOpen)
            wall.move(dir);
    }

    /**
     * Apply the wallpaper strip's focused thumb through wallpaper.sh. The
     * surface stays open so the pick can be iterated. No-op unless the
     * wallpaper surface is open.
     */
    function wallpaperActivate() {
        if (pill.wallpaperOpen)
            wall.activate();
    }

    readonly property bool wallpaperSearching: pill.wallpaperOpen && wall.searching

    /**
     * Route the first printable keystroke over the open wallpaper strip into a
     * DuckDuckGo search seeded with that character. No-op unless the wallpaper
     * surface is open.
     */
    function wallpaperType(ch) {
        if (pill.wallpaperOpen)
            wall.startSearch(ch);
    }

    /**
     * Slide the open power surface's keyboard focus by `dir` tiles; +1 is right
     * and -1 is left. No-op unless the power surface is open.
     */
    function powerMove(dir) {
        if (pill.powerOpen)
            power.move(dir);
    }

    /**
     * Enter pressed on the open power surface's focused tile: fires a safe tile
     * at once, latches a destructive tile's heat hold. Returns true when a tile
     * consumed the key. No-op (false) unless the power surface is open.
     */
    function powerPress() {
        return pill.powerOpen ? power.pressFocused() : false;
    }

    /**
     * Enter released on the open power surface: drains an unfinished destructive
     * hold so a key let go before the fill completes never confirms.
     */
    function powerRelease() {
        if (pill.powerOpen)
            power.releaseFocused();
    }

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
            shadowColor: Qt.rgba(0, 0, 0, Theme.shadowOpacity)
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
            color: stat.hot ? Theme.vermLit : Theme.iconDim
            stroke: 1.7
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: stat.text
            color: stat.hot ? Theme.vermLit : Theme.cream
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
            screenName: pill.screenName
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
            color: Theme.cream
            font.family: Theme.font
            font.pixelSize: 16 * pill.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
        }
    }

    Launcher {
        id: launcher
        anchors.centerIn: parent
        s: pill.s
        open: pill.launcherOpen
        morphCloseness: pill.morphCloseness
        onRequestClose: pill.requestClose()
    }

    Clipboard {
        id: clip
        s: pill.s
        open: pill.clipboardOpen
        morphCloseness: pill.morphCloseness
        onRequestClose: pill.requestClose()
    }

    Wallpaper {
        id: wall
        s: pill.s
        open: pill.wallpaperOpen
        morphCloseness: pill.morphCloseness
        onRequestClose: pill.requestClose()
    }

    Power {
        id: power
        s: pill.s
        open: pill.powerOpen
        morphCloseness: pill.morphCloseness
        onRequestClose: pill.requestClose()
    }

    Link {
        id: link
        s: pill.s
        open: pill.linkOpen
        morphCloseness: pill.morphCloseness
        onRequestClose: pill.requestClose()
    }

    Web {
        id: web
        s: pill.s
        open: pill.webOpen
        morphCloseness: pill.morphCloseness
        onRequestClose: pill.requestClose()
    }

    ThemePicker {
        id: themes
        s: pill.s
        open: pill.themesOpen
        morphCloseness: pill.morphCloseness
        onRequestClose: pill.requestClose()
    }

    /**
     * `expanded` is always true: the rest pill already shows the workspace dots,
     * so the workspace-switch OSD flash would only duplicate them.
     */
    Osd {
        id: osd
        anchors.fill: parent
        anchors.topMargin: 12 * pill.s
        anchors.leftMargin: 18 * pill.s
        anchors.rightMargin: 18 * pill.s
        anchors.bottomMargin: 12 * pill.s
        s: pill.s
        screenName: pill.screenName
        suppressed: pill.surfaceOpen
        expanded: true
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
                color: Theme.dim
                font.family: Theme.font
                font.pixelSize: 9 * pill.s
                font.weight: Font.DemiBold
            }
        }
    }
}
