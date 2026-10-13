import QtQuick
import QtQuick.Effects
import "../services"

/**
 * Body of the floating dots beside the notch (bell, agents): a pill-round
 * card with the notch's gradient, a hairline border, a top sheen and a drop
 * shadow. `dissolve` (0..1) fades and shrinks it as a dot docks into a surface.
 */
Rectangle {
    id: body

    property real s: 1
    property real dissolve: 0
    property color borderColor: Theme.border

    radius: height / 2
    opacity: 1 - dissolve
    scale: 1 - 0.4 * dissolve
    visible: opacity > 0.01
    gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.alpha(Theme.cardTop, Flags.pillOpacity) }
        GradientStop { position: 1.0; color: Qt.alpha(Theme.cardBot, Flags.pillOpacity) }
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Theme.shadow
        shadowBlur: 0.7
        shadowVerticalOffset: 3 * body.s
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: body.borderColor
        Behavior on border.color { ColorAnimation { duration: Motion.standard } }
    }

    /** Inner sheen along the top. */
    Rectangle {
        x: body.radius * 0.6
        y: 1
        width: Math.max(0, body.width - body.radius * 1.2)
        height: 1
        color: Theme.sheen
    }
}
