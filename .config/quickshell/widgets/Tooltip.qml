import QtQuick
import QtQuick.Effects
import "../services"

/**
 * Hint bubble for pill controls. Anchored to its parent control and
 * centred on it; `placement` decides whether the bubble floats above (pointer
 * down) or below (pointer up) so chips near the pill edge never clip off-screen.
 * The host sets `show` from the control's own HoverHandler; the bubble arms
 * after a hover delay, fades in slowly and out fast.
 *
 * Non-interactive by design: no MouseArea or HoverHandler lives here, so it
 * never steals pointer events from the control it describes.
 */
Item {
    id: root

    property real s: 1
    property string title: ""
    property bool show: false
    property string placement: "above"

    readonly property bool below: placement === "below"
    readonly property real pointerH: 5 * s
    readonly property real gap: 5 * s

    property bool armed: false

    width: bubble.width
    height: bubble.height + pointerH
    z: 20

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: below ? undefined : parent.top
    anchors.bottomMargin: below ? 0 : gap
    anchors.top: below ? parent.bottom : undefined
    anchors.topMargin: below ? gap : 0

    visible: armed || opacity > 0.01
    opacity: armed ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: root.armed ? Motion.standard : Motion.fast } }

    Timer {
        id: delay
        interval: 470
        onTriggered: root.armed = true
    }
    onShowChanged: {
        if (show) {
            delay.restart();
        } else {
            delay.stop();
            armed = false;
        }
    }

    Rectangle {
        id: bubble
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: root.below ? undefined : parent.top
        anchors.bottom: root.below ? parent.bottom : undefined
        width: titleText.implicitWidth + 22 * root.s
        height: titleText.implicitHeight + 14 * root.s
        radius: 9 * root.s
        border.width: 1
        border.color: Theme.frameBorder
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.cardTop }
            GradientStop { position: 1.0; color: Theme.cardBot }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.shadow
            shadowBlur: 0.6
            shadowVerticalOffset: 4 * root.s
        }
    }

    Text {
        id: titleText
        anchors.centerIn: bubble
        text: root.title
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 11 * root.s
        font.weight: Font.Bold
    }

    Canvas {
        width: 11 * root.s
        height: root.pointerH
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: root.below ? parent.top : undefined
        anchors.bottom: root.below ? undefined : parent.bottom
        property color fill: Theme.cardBot
        onFillChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = fill;
            ctx.beginPath();
            if (root.below) {
                ctx.moveTo(0, height);
                ctx.lineTo(width, height);
                ctx.lineTo(width / 2, 0);
            } else {
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width / 2, height);
            }
            ctx.closePath();
            ctx.fill();
        }
    }
}
