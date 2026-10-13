import QtQuick
import "../services"

/** Three bouncing equaliser bars, the "music is playing" mark. */
Row {
    id: root

    property real s: 1
    property bool running: true
    property color color: Theme.accent

    spacing: 2 * s

    Repeater {
        model: 3

        Rectangle {
            id: bar
            required property int index
            anchors.verticalCenter: parent.verticalCenter
            width: 2.5 * root.s
            radius: width / 2
            color: root.color
            height: 5 * root.s

            SequentialAnimation on height {
                running: root.running && root.visible
                loops: Animation.Infinite
                PauseAnimation { duration: bar.index * 140 }
                NumberAnimation { to: 13 * root.s; duration: 320 + bar.index * 60; easing.type: Easing.InOutSine }
                NumberAnimation { to: 4 * root.s; duration: 300 + bar.index * 80; easing.type: Easing.InOutSine }
            }
        }
    }
}
