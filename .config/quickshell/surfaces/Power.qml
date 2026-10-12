pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import "../services"
import "../widgets"

/**
 * Power surface, after Ambxst's power menu: a row of icon buttons with an
 * accent highlight that slides elastically to the selected one. A hairline
 * splits the safe group (lock, sleep; fire on tap) from the destructive group
 * (logout, restart, shutdown; press-and-hold). Holding a destructive button
 * ramps a bottom-up heat fill, releasing early drains it, so a stray click can
 * never reboot the machine. The label below names the selected action.
 *
 * Up/Down (or Ctrl+K/Ctrl+J) or hover move the selection along the row. Enter fires a safe button at once;
 * on a destructive button a held Enter drives the same heat fill as a pointer
 * hold, so the keyboard can never reboot on a single keystroke either.
 */
PillSurface {
    id: root

    mTop: 16
    mLeft: 16
    mRight: 16
    mBottom: 12

    property int focusIndex: 0
    property bool keyHeld: false

    readonly property var actions: [
        { label: "Lock",     icon: Icons.lock,     confirm: false, argv: ["loginctl", "lock-session"] },
        { label: "Sleep",    icon: Icons.suspend,  confirm: false, argv: ["systemctl", "suspend"] },
        { label: "Logout",   icon: Icons.logout,   confirm: true,  argv: ["niri", "msg", "action", "quit", "--skip-confirmation"] },
        { label: "Restart",  icon: Icons.reboot,   confirm: true,  argv: ["systemctl", "reboot"] },
        { label: "Shutdown", icon: Icons.shutdown, confirm: true,  argv: ["systemctl", "poweroff"] }
    ]

    /** The hairline sits before this index. */
    readonly property int splitAt: 2
    readonly property real btn: 48 * s
    readonly property real gap: 8 * s
    readonly property real splitW: 1 + gap

    function btnX(i) {
        return i * (btn + gap) + (i >= splitAt ? splitW : 0);
    }

    function run(a) {
        Quickshell.execDetached(a.argv);
        root.requestClose();
    }

    /** Releases any held heat so the selection never drags a half-filled button. */
    function move(dir) {
        keyHeld = false;
        focusIndex = Math.max(0, Math.min(actions.length - 1, focusIndex + dir));
    }

    onOpenChanged: {
        if (open) {
            focusIndex = 0;
            Qt.callLater(root.forceActiveFocus);
        }
        keyHeld = false;
    }

    function isConfirmKey(e) {
        return e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space;
    }

    Keys.onUpPressed: move(-1)
    Keys.onDownPressed: move(1)
    Keys.onPressed: (e) => {
        if (e.modifiers & Qt.ControlModifier && (e.key === Qt.Key_J || e.key === Qt.Key_K)) {
            move(e.key === Qt.Key_J ? 1 : -1);
            e.accepted = true;
            return;
        }
        if (!isConfirmKey(e))
            return;
        e.accepted = true;
        if (e.isAutoRepeat)
            return;
        if (actions[focusIndex].confirm)
            keyHeld = true;
        else
            run(actions[focusIndex]);
    }
    Keys.onReleased: (e) => {
        if (isConfirmKey(e) && !e.isAutoRepeat) {
            keyHeld = false;
            e.accepted = true;
        }
    }

    Item {
        id: row
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.btnX(root.actions.length - 1) + root.btn
        height: root.btn

        ElasticHighlight {
            tx: root.btnX(root.focusIndex)
            ty: 0
            tw: root.btn
            th: root.btn
            radius: 16 * root.s
        }

        Rectangle {
            x: root.btnX(root.splitAt) - root.splitW + (root.gap - 1) / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 24 * root.s
            color: Theme.hair
        }

        Repeater {
            model: root.actions

            delegate: Item {
                id: button
                required property int index
                required property var modelData

                readonly property bool selected: root.focusIndex === index
                readonly property bool keyDriving: selected && root.keyHeld && modelData.confirm

                x: root.btnX(index)
                width: root.btn
                height: root.btn

                onKeyDrivingChanged: keyDriving ? heat.press() : heat.release()

                /** Heat fill, clipped to the highlight's corners. */
                ClippingRectangle {
                    anchors.fill: parent
                    radius: 16 * root.s
                    color: "transparent"
                    visible: heat.holding

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.height * heat.hold
                        color: Qt.alpha(Theme.onAccent, 0.25)
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    size: 20 * root.s
                    text: button.modelData.icon
                    color: button.selected ? Theme.onAccent : Theme.icon
                }

                HeatHold {
                    id: heat
                    onConfirmed: root.run(button.modelData)
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.focusIndex = button.index
                    onExited: if (button.modelData.confirm) heat.cancel()
                    onPressed: if (button.modelData.confirm) heat.press()
                    onReleased: if (button.modelData.confirm) heat.release()
                    onClicked: if (!button.modelData.confirm) root.run(button.modelData)
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: row.bottom
        anchors.topMargin: 12 * root.s
        readonly property var act: root.actions[root.focusIndex]
        text: act.confirm ? act.label + " — hold" : act.label
        color: act.confirm ? Theme.accent : Theme.textSubtle
        font.family: Theme.font
        font.pixelSize: 11 * root.s
        font.weight: Font.Medium
        font.letterSpacing: 0.4 * root.s
    }
}
