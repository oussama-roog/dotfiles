//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "services"

/**
 * Entry point. Two layer-shell windows per monitor:
 *   - `reserve`  an empty strip claiming an exclusive zone the height of the
 *                rest pill, so tiled windows always sit below it.
 *   - `overlay`  a full-screen transparent Overlay layer hosting the morphing
 *                pill anchored at top-centre.
 *
 * Surfaces open via `qs ipc call pill <name>`: launcher, web, clipboard,
 * wallpaper, power, themes, notifications, claude. `hide` closes whatever is open.
 */
ShellRoot {
    id: root

    property string openMon: ""
    property string openSurface: ""

    Component.onCompleted: Themes.refresh()

    IpcHandler {
        target: "pill"
        function launcher(): void      { root.toggle("launcher"); }
        function web(): void           { root.toggle("web"); }
        function clipboard(): void     { root.toggle("clipboard"); }
        function wallpaper(): void     { root.toggle("wallpaper"); }
        function power(): void         { root.toggle("power"); }
        function themes(): void        { root.toggle("themes"); }
        function notifications(): void { root.toggle("notifications"); }
        function claude(): void        { root.toggle("claude"); }
        function hide(): void          { root.close(); }
    }

    function toggle(surface) {
        var mon = Quickshell.screens[0].name;
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

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            readonly property real s: modelData ? (modelData.height / 1080) * Flags.uiScale : 1
            readonly property real zone: 38 * s

            screen: modelData
            color: "transparent"
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: zone
            aboveWindows: true
            anchors { top: true; left: true; right: true }
            implicitHeight: zone

            mask: Region {}
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlay
            required property var modelData
            readonly property real s: modelData ? (modelData.height / 1080) * Flags.uiScale : 1
            readonly property string surface: root.openMon === modelData.name ? root.openSurface : ""
            readonly property bool surfaceOpen: surface.length > 0

            screen: modelData
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: surfaceOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "pill"
            anchors { top: true; left: true; right: true; bottom: true }

            // Only the pills take input, unless a surface is open: then the whole
            // screen does, so a click outside closes it.
            mask: surfaceOpen ? fullRegion : barRegion
            Region {
                id: barRegion
                regions: [pillRegion, notifRegion, claudeRegion]
            }
            Region {
                id: notifRegion
                item: notifPill
            }
            Region {
                id: claudeRegion
                item: claudePill
            }
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
                enabled: overlay.surfaceOpen
                acceptedButtons: Qt.AllButtons
                onPressed: (mouse) => {
                    var inside = mouse.x >= pillRegion.x && mouse.x <= pillRegion.x + pillRegion.width
                        && mouse.y >= pillRegion.y && mouse.y <= pillRegion.y + pillRegion.height;
                    if (!inside || mouse.y <= pillRegion.y + 40 * pill.s)
                        root.close();
                }
            }

            // Surfaces take focus themselves; keys they don't handle (Escape)
            // bubble up here.
            FocusScope {
                id: focusScope
                anchors.fill: parent
                focus: overlay.surfaceOpen
                Keys.onEscapePressed: root.close()

                Pill {
                    id: pill
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    s: overlay.s
                    surface: overlay.surface
                    onRequestClose: root.close()
                }

                /**
                 * Floats beside the main pill's right edge, on top of it. With
                 * the notification centre open it docks its bell in the
                 * centre's header slot (Notifications.bellSlot), right of the
                 * unread count; both ends follow the notch's live edge.
                 */
                NotifPill {
                    id: notifPill
                    z: 1
                    readonly property real restLeft: 26 * overlay.s
                    readonly property real dockLeft: -(16 + 12) * overlay.s - dotW / 2
                    anchors.top: parent.top
                    anchors.topMargin: (4 + 4 * mergeT) * overlay.s
                    anchors.left: pill.right
                    anchors.leftMargin: restLeft + (dockLeft - restLeft) * mergeT
                    s: overlay.s
                    merged: overlay.surface === "notifications"
                    onBellClicked: root.toggle("notifications")
                }

                /**
                 * The bell's mirror on the left: Claude sessions and media.
                 * With the agents centre open it docks its sparkle in the
                 * centre's header slot (Agents.dotSlot), left of the title.
                 */
                ClaudePill {
                    id: claudePill
                    z: 1
                    readonly property real restRight: 26 * overlay.s
                    readonly property real dockRight: -(16 + 12) * overlay.s - dotW / 2
                    anchors.top: parent.top
                    anchors.topMargin: (4 + 4 * mergeT) * overlay.s
                    anchors.right: pill.left
                    anchors.rightMargin: restRight + (dockRight - restRight) * mergeT
                    s: overlay.s
                    merged: overlay.surface === "claude"
                    onDotClicked: root.toggle("claude")
                }
            }

            onSurfaceOpenChanged: if (surfaceOpen) focusScope.forceActiveFocus()
        }
    }
}
