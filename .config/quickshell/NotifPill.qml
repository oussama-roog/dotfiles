pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import "services"
import "widgets"

/**
 * Floating dot beside the notch, holding the notification bell. An accent
 * dot marks unread; clicking the bell opens the notifications surface. A new
 * notification stretches it to the right into a one-line pill, with the same
 * overshoot as the main pill, and it shrinks back once the queue drains.
 *
 * While the notification centre is open (`merged`) the dot flies into it,
 * on top of everything: its round body dissolves as it enters, and the bell
 * docks in the centre's header as its icon. Closing gives the bell its body
 * back as it flies out. shell.qml positions it from `mergeT`, relative to the
 * notch's live right edge, so it rides the centre as that grows and shrinks.
 */
Item {
    id: root

    property real s: 1

    property bool merged: false

    signal bellClicked()

    /** 0 = beside the notch, 1 = docked in the centre's header. */
    property real mergeT: merged ? 1 : 0
    Behavior on mergeT { NumberAnimation { duration: Motion.morph; easing.type: root.merged ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }
    /** The body dissolves over the second half of the flight in. */
    readonly property real dissolve: Math.max(0, Math.min(1, (mergeT - 0.35) / 0.5))

    /** Popups are in the centre's list, so they never toast after it was open. */
    onMergedChanged: Notifs.popups = []

    readonly property bool active: Notifs.popups.length > 0 && !merged
    readonly property real dotW: 34 * s
    readonly property real pad: 18 * s
    readonly property real toastW: active && toastLoader.item
        ? Math.max(180 * s, Math.min(toastLoader.item.implicitWidth, 420 * s)) + pad + 12 * s : 0

    width: dotW + toastW
    height: dotW
    Behavior on width { NumberAnimation { duration: Motion.morph; easing.type: root.active ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: height / 2
        opacity: 1 - root.dissolve
        scale: 1 - 0.4 * root.dissolve
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
            shadowVerticalOffset: 3 * root.s
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Theme.border
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

    Item {
        width: root.dotW
        height: root.height

        Icon {
            anchors.centerIn: parent
            size: 16 * root.s
            text: Icons.bell
            color: root.active || root.merged || bellArea.containsMouse ? Theme.accent : Theme.icon
        }
        Rectangle {
            x: parent.width / 2 + 3 * root.s
            y: parent.height / 2 - 8 * root.s
            width: 6 * root.s
            height: 6 * root.s
            radius: width / 2
            color: Theme.accent
            scale: Notifs.unread > 0 && !Flags.dnd ? 1 : 0
            Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeOpen; easing.overshoot: Motion.overshoot } }
        }
        MouseArea {
            id: bellArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.bellClicked()
        }
    }

    Rectangle {
        x: root.dotW
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 16 * root.s
        color: Theme.hair
        opacity: toastLoader.opacity
    }

    Loader {
        id: toastLoader
        active: root.active
        x: root.dotW + 12 * root.s
        width: Math.max(0, root.width - x - root.pad)
        height: root.height
        clip: true
        transformOrigin: Item.Left
        opacity: root.active ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
        scale: root.active ? 1 : 0.86
        Behavior on scale { NumberAnimation { duration: Motion.morph; easing.type: root.active ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }

        sourceComponent: Toast {
            s: root.s
            more: Notifs.popups.length - 1
            notif: Notifs.popups.length > 0 ? Notifs.popups[Notifs.popups.length - 1] : null
        }
    }
}
