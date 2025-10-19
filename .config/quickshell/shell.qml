import Quickshell
import Quickshell.Hyprland
import QtQuick
import "components"

Scope {
    id: root

    ClockPopout {
        id: clockPopout
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 5
                left: 10
                right: 10
            }

            implicitHeight: 40
            exclusiveZone: 40

            color: "transparent"

            Item {
                anchors.fill: parent

                Workspaces {
                    anchors {
                        left: parent.left
                        leftMargin: 20
                        verticalCenter: parent.verticalCenter
                    }
                }

                Clock {
                    anchors.centerIn: parent
                    onClicked: clockPopout.show()
                }
            }
        }
    }

    Component.onCompleted: {
        Hyprland.refreshWorkspaces();
    }
}
