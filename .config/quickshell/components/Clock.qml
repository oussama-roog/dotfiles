import Quickshell
import QtQuick

Rectangle {
    id: root
    color: "#000000"
    radius: 20
    width: 250
    height: 40

    signal clicked()

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
        enabled: true
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm:ss")
        color: "#FFFFFF"
        font.pixelSize: 14
        font.family: "monospace"
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
