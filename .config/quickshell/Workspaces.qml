pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "Singletons"

/**
 * Workspace dots for the pill, powered by Niri IPC via NiriSpaces singleton.
 * Active workspace is a wider filled dot (stick); the rest are small and dim.
 * Clicking a dot focuses that workspace via niri msg.
 */
Item {
    id: workspaces

    property string screenName: ""
    property real s: 1
    property real stickW: 17 * s
    property real dotW: 5 * s
    property real gap: 4 * s

    readonly property var wsModel: NiriSpaces.workspaces

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Process {
        id: focusProc
    }

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: workspaces.gap

        Repeater {
            model: workspaces.wsModel

            delegate: Item {
                id: slot

                required property var modelData

                readonly property bool isActive: modelData.is_active

                Layout.preferredWidth: slot.isActive ? workspaces.stickW : workspaces.dotW
                Layout.preferredHeight: 22 * workspaces.s
                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: Motion.fast; easing.type: Motion.easeStandard }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: workspaces.dotW
                    radius: height / 2
                    color: slot.isActive ? Theme.vermLit : Theme.cream
                    opacity: slot.isActive ? 1.0 : 0.3
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.leftMargin: -workspaces.gap / 2
                    anchors.rightMargin: -workspaces.gap / 2
                    anchors.topMargin: -8 * workspaces.s
                    anchors.bottomMargin: -8 * workspaces.s
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        focusProc.exec(["niri", "msg", "action", "focus-workspace", "--index",
                                        String(slot.modelData.idx)]);
                    }
                }
            }
        }
    }
}
