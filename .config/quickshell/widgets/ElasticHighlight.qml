import QtQuick
import "../services"

/**
 * Sliding selection background, after Ambxst's ActionGrid: two trackers chase
 * the target geometry (`tx`, `ty`, `tw`, `th`), a fast leading one and a slow
 * trailing one, and the highlight spans both, so it stretches toward the new
 * item and then catches up. Accent fill with the pill's top sheen. Place it
 * under the items in the same coordinate space as the target.
 */
Item {
    id: root

    property real tx: 0
    property real ty: 0
    property real tw: 0
    property real th: 0
    property real radius: 10
    property bool shown: true

    property real t1x: tx
    property real t1y: ty
    property real t1w: tw
    property real t1h: th
    property real t2x: tx
    property real t2y: ty
    property real t2w: tw
    property real t2h: th

    Behavior on t1x { NumberAnimation { duration: Motion.standard / 3; easing.type: Easing.OutSine } }
    Behavior on t1y { NumberAnimation { duration: Motion.standard / 3; easing.type: Easing.OutSine } }
    Behavior on t1w { NumberAnimation { duration: Motion.standard / 3; easing.type: Easing.OutSine } }
    Behavior on t1h { NumberAnimation { duration: Motion.standard / 3; easing.type: Easing.OutSine } }
    Behavior on t2x { NumberAnimation { duration: Motion.standard; easing.type: Easing.OutSine } }
    Behavior on t2y { NumberAnimation { duration: Motion.standard; easing.type: Easing.OutSine } }
    Behavior on t2w { NumberAnimation { duration: Motion.standard; easing.type: Easing.OutSine } }
    Behavior on t2h { NumberAnimation { duration: Motion.standard; easing.type: Easing.OutSine } }

    x: Math.min(t1x, t2x)
    y: Math.min(t1y, t2y)
    width: Math.max(t1x + t1w, t2x + t2w) - x
    height: Math.max(t1y + t1h, t2y + t2h) - y

    opacity: shown ? 1 : 0
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: Motion.fast } }

    Rectangle {
        anchors.fill: parent
        radius: Math.min(root.radius, height / 2)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.accent }
            GradientStop { position: 1.0; color: Theme.accentDark }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: parent.radius * 0.6
            anchors.rightMargin: parent.radius * 0.6
            height: 1
            color: Qt.rgba(1, 1, 1, 0.22)
        }
    }
}
