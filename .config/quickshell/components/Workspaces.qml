import Quickshell
import Quickshell.Hyprland
import QtQuick

Rectangle {
    color: "#000000"
    radius: 20
    width: workspacesRow.width + 24
    height: 40

    Row {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                required property HyprlandWorkspace modelData

                height: 10
                radius: 5

                width: modelData === Hyprland.focusedWorkspace ? 30 : 10
                color: modelData === Hyprland.focusedWorkspace ? "#FFFFFF" : "#808080"

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch('workspace ' + modelData.id)
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
