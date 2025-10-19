import Quickshell
import QtQuick

PanelWindow {
    id: popout

    property bool shouldBeVisible: false

    screen: Quickshell.screens[0]
    visible: shouldBeVisible

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        left: (screen.width - 600) / 2
        right: (screen.width - 600) / 2
    }

    implicitHeight: 400

    exclusiveZone: 0
    focusable: true
    aboveWindows: true

    function show() {
        shouldBeVisible = true;
    }

    function hide() {
        shouldBeVisible = false;
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 20
        border.color: "#89b4fa"
        border.width: 2

        Text {
            anchors.centerIn: parent
            text: "Clock Popout\n(Empty for now)"
            color: "#cdd6f4"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: popout.hide()
        }
    }
}
