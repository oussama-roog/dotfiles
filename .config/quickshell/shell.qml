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
 * Removed surfaces: launcher, keybinds, recorder, workspaces-settings,
 * stash, spaceapps, appearance, updates, display, input, look, idlelock,
 * animation, fontpicker.
 * Added surface: web (web-app launcher ported from old config).
 */
ShellRoot {
    id: root

    property string openMon: ""
    property string openSurface: ""
    property string peekMon: ""

    Component.onCompleted: {
        Devices.restore();
    }

    /** Post a one-shot update toast after a reload if the marker file exists. */
    Timer {
        interval: 2500
        running: true
        onTriggered: updatedToast.running = true
    }
    Process {
        id: updatedToast
        command: ["sh", "-c",
            "m=\"${XDG_STATE_HOME:-$HOME/.local/state}/ricelin/updated\"; [ -f \"$m\" ] || exit 0; "
            + "b=$(cat \"$m\"); rm -f \"$m\"; "
            + "gdbus call --session --dest org.freedesktop.Notifications "
            + "--object-path /org/freedesktop/Notifications "
            + "--method org.freedesktop.Notifications.Notify "
            + "Ricelin 0 '' 'Ricelin updated' \"$b\" '[]' '{}' 5000 >/dev/null 2>&1"]
    }



    /** Idle inhibitor window — keeps screen awake while Keep Awake is on. */
    PanelWindow {
        id: inhibitWin
        visible: Flags.keepAwake
        implicitWidth: 1
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "pill-inhibit"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors { top: true; left: true }
        IdleInhibitor { window: inhibitWin; enabled: Flags.keepAwake }
    }

    /** systemd-inhibit keeps hypridle from firing while Keep Awake is on. */
    Process {
        running: Flags.keepAwake
        command: ["systemd-inhibit", "--what=idle:sleep", "--who=Ricelin",
                  "--why=keep awake", "--mode=block", "sleep", "infinity"]
    }

    // ─── IPC handlers ────────────────────────────────────────────────────────

    IpcHandler {
        target: "pill"
        function mixer(): void    { root.toggleSurface("", "mixer"); }
        function calendar(): void { root.toggleSurface("", "calendar"); }
        function power(): void    { root.toggleSurface("", "power"); }
        function link(): void     { root.toggleSurface("", "link"); }
        function battery(): void  { root.toggleSurface("", "battery"); }
        function settings(): void { root.toggleSurface("", "settings"); }
        function sysmon(): void   { root.toggleSurface("", "sysmon"); }
        function system(): void   { root.toggleSurface("", "sysmon"); }
        function clipboard(): void { root.toggleSurface("", "clipboard"); }
        function wallpaper(): void { root.toggleSurface("", "wallpaper"); }
        function web(): void      { root.toggleSurface("", "web"); }
        function media(): void {
            if (Players.list.length > 0)
                root.toggleSurface("", "media");
        }
        function peek(): void { root.peek(""); }
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

    function peek(mon) {
        if (!mon || mon === "") mon = Quickshell.screens[0].name;
        root.peekMon = root.peekMon === mon ? "" : mon;
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
            readonly property bool modal: surfaceOpen || pill.held || pill.quickChoosing

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
                width: baseW + pill.inputPadRight
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
                    if (overlay.surfaceOpen) {
                        var inside = mouse.x >= pillRegion.x && mouse.x <= pillRegion.x + pillRegion.width
                            && mouse.y >= pillRegion.y && mouse.y <= pillRegion.y + pillRegion.height;
                        if (!inside)
                            root.close();
                        else if (mouse.y <= pillRegion.y + 40 * pill.s)
                            pill.surfaceBack();
                    } else {
                        pill.pinned = false;
                        root.peekMon = "";
                    }
                }
            }

            FocusScope {
                id: focusScope
                anchors.fill: parent
                focus: overlay.surfaceOpen

                HoverHandler {
                    onHoveredChanged: pill.hovered = hovered
                }

                Keys.onEscapePressed: {
                    if (!pill.linkBack()) {
                        root.close();
                    }
                }
                Keys.onUpPressed:    (e) => { e.accepted = pill.mixerStep(1) || pill.settingsMove(-1); }
                Keys.onDownPressed:  (e) => { e.accepted = pill.mixerStep(-1) || pill.settingsMove(1); }
                Keys.onLeftPressed:  (e) => {
                    if (pill.mixerOpen) { pill.mixerFocusMove(-1); e.accepted = true; }
                    else if (pill.wallpaperOpen) { pill.wallpaperMove(-1); e.accepted = true; }
                    else if (pill.powerOpen) { pill.powerMove(-1); e.accepted = true; }
                    else if (pill.settingsLike) { pill.settingsAdjust(-1); e.accepted = true; }
                }
                Keys.onRightPressed: (e) => {
                    if (pill.mixerOpen) { pill.mixerFocusMove(1); e.accepted = true; }
                    else if (pill.wallpaperOpen) { pill.wallpaperMove(1); e.accepted = true; }
                    else if (pill.powerOpen) { pill.powerMove(1); e.accepted = true; }
                    else if (pill.settingsLike) { pill.settingsAdjust(1); e.accepted = true; }
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
                    } else if (pill.settingsLike) {
                        if (!e.isAutoRepeat) pill.settingsActivate();
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
                    forcePinned: root.peekMon === overlay.modelData.name

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
