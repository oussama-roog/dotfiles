//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Singletons"

/**
 * Washi pill top shell — Niri edition.
 *
 * Two layer-shell windows per monitor:
 *   - `reserve`  a zero-content strip claiming an exclusive zone the height of
 *                the rest pill, so tiled windows always sit below it.
 *   - `overlay`  a full-screen transparent Overlay layer hosting the morphing
 *                pill anchored at top-centre.
 *
 * All Hyprland IPC has been replaced with Niri event-stream and niri msg calls.
 * Surfaces (opened via `qs ipc call pill <name>`): launcher, web, clipboard,
 * wallpaper, power, themes, link (notification inbox).
 */
ShellRoot {
    id: root

    property string openMon: ""
    property string openSurface: ""

    Component.onCompleted: {
        Devices.restore();
        Themes.refresh();
    }

    // ─── IPC handlers ────────────────────────────────────────────────────────

    IpcHandler {
        target: "pill"
        function power(): void    { root.toggleSurface("", "power"); }
        function link(): void     { root.toggleSurface("", "link"); }
        function clipboard(): void { root.toggleSurface("", "clipboard"); }
        function wallpaper(): void { root.toggleSurface("", "wallpaper"); }
        function web(): void      { root.toggleSurface("", "web"); }
        function launcher(): void { root.toggleSurface("", "launcher"); }
        function themes(): void   { root.toggleSurface("", "themes"); }
        function hide(): void { root.close(); }
    }

    // ─── Surface routing helpers ──────────────────────────────────────────────

    function toggleSurface(mon, surface) {
        if (!mon || mon === "") mon = Quickshell.screens[0].name;
        if (root.openMon === mon && root.openSurface === surface) {
            root.close();
            return;
        }
        root.openMon = mon;
        root.openSurface = surface;
    }

    function close() {
        root.openMon = "";
        root.openSurface = "";
    }

    // ─── Per-monitor windows ──────────────────────────────────────────────────

    /** Exclusion-zone strip (no content, just reserve space). */
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: reserve
            required property var modelData
            readonly property real s: modelData ? (modelData.height / 1080) * Flags.uiScale : 1
            readonly property real topGap: 8 * s
            readonly property real restHeight: 38 * s

            screen: modelData
            color: "transparent"
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: restHeight + topGap
            aboveWindows: true

            anchors { top: true; left: true; right: true }
            implicitHeight: restHeight + topGap

            mask: emptyReserve
            Region { id: emptyReserve }
        }
    }

    /** Full-screen overlay hosting the pill. */
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlay
            required property var modelData
            readonly property real s: modelData ? (modelData.height / 1080) * Flags.uiScale : 1
            readonly property real topGap: 8 * s
            readonly property string surface: root.openMon === modelData.name ? root.openSurface : ""
            readonly property bool surfaceOpen: surface.length > 0
            readonly property bool modal: surfaceOpen

            screen: modelData
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: surfaceOpen
                ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "pill"

            anchors { top: true; left: true; right: true; bottom: true }

            mask: modal ? fullRegion : pillRegion
            Region {
                id: pillRegion
                readonly property real baseW: Math.max(pill.width, pill.targetW)
                x: pill.x + (pill.width - baseW) / 2
                y: pill.y
                width: baseW
                height: Math.max(pill.height, pill.targetH)
            }
            Region {
                id: fullRegion
                width: overlay.width
                height: overlay.height
            }

            MouseArea {
                anchors.fill: parent
                enabled: overlay.modal
                acceptedButtons: Qt.AllButtons
                onPressed: (mouse) => {
                    var inside = mouse.x >= pillRegion.x && mouse.x <= pillRegion.x + pillRegion.width
                        && mouse.y >= pillRegion.y && mouse.y <= pillRegion.y + pillRegion.height;
                    if (!inside)
                        root.close();
                    else if (mouse.y <= pillRegion.y + 40 * pill.s)
                        pill.surfaceBack();
                }
            }

            FocusScope {
                id: focusScope
                anchors.fill: parent
                focus: overlay.surfaceOpen

                Keys.onEscapePressed: {
                    if (!pill.linkBack()) {
                        root.close();
                    }
                }
                Keys.onLeftPressed:  (e) => {
                    if (pill.wallpaperOpen) { pill.wallpaperMove(-1); e.accepted = true; }
                    else if (pill.powerOpen) { pill.powerMove(-1); e.accepted = true; }
                }
                Keys.onRightPressed: (e) => {
                    if (pill.wallpaperOpen) { pill.wallpaperMove(1); e.accepted = true; }
                    else if (pill.powerOpen) { pill.powerMove(1); e.accepted = true; }
                }

                Keys.onPressed: (e) => {
                    if (pill.wallpaperOpen && !pill.wallpaperSearching
                        && e.text.length === 1 && e.text > " ") {
                        pill.wallpaperType(e.text);
                        e.accepted = true;
                        return;
                    }
                    if (e.key !== Qt.Key_Return && e.key !== Qt.Key_Enter && e.key !== Qt.Key_Space)
                        return;
                    if (pill.wallpaperOpen) {
                        if (!e.isAutoRepeat) pill.wallpaperActivate();
                        e.accepted = true;
                    } else if (pill.powerOpen) {
                        if (!e.isAutoRepeat) pill.powerPress();
                        e.accepted = true;
                    }
                }
                Keys.onReleased: (e) => {
                    if (e.isAutoRepeat) return;
                    if ((e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space)
                        && pill.powerOpen) {
                        pill.powerRelease();
                        e.accepted = true;
                    }
                }

                Pill {
                    id: pill
                    anchors.top: parent.top
                    anchors.topMargin: overlay.topGap
                    anchors.horizontalCenter: parent.horizontalCenter
                    s: overlay.s
                    screenName: overlay.modelData.name
                    barWindow: overlay
                    surface: overlay.surface

                    onRequestSurface: (name) => root.toggleSurface(overlay.modelData.name, name)
                    onRequestClose: root.close()
                }
            }

            onSurfaceOpenChanged: if (surfaceOpen) focusScope.forceActiveFocus()

            Connections {
                target: pill
                function onWallpaperSearchingChanged() {
                    if (!pill.wallpaperSearching && overlay.surfaceOpen)
                        focusScope.forceActiveFocus();
                }
            }
        }
    }
}
