pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "services"
import "widgets"

/**
 * Inline toast: one line that grows out of the bell on the right of the rest
 * bar. App icon, summary, dimmed body, action pills, a "+N" when more are
 * queued, and a dismiss glyph. Draws no background; the pill body provides
 * it. Clicking jumps to the source app; dismiss and action pills consume
 * their clicks. Auto-expires via Notifs.expireAt unless critical.
 */
Item {
    id: root

    property real s: 1
    property bool live: true
    property int more: 0
    required property var notif

    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    readonly property var acts: notif.actions.filter(function(a) { return a.text.length > 0; }).slice(0, 2)
    readonly property real gap: 8 * s
    readonly property real summaryW: Math.min(summary.implicitWidth, 200 * s)

    /** Natural width; the pill clamps it. Body text gives way first. */
    implicitWidth: iconTile.width + gap + summaryW
        + (body.text.length ? gap + Math.min(body.implicitWidth, 220 * s) : 0)
        + (acts.length ? gap + actions.implicitWidth : 0)
        + (more > 0 ? gap + moreText.implicitWidth : 0)
        + gap + dismiss.width
    implicitHeight: 22 * s

    /**
     * The deadline is snapshotted per notification: binding the interval to
     * Notifs.expireAt restarts the timer (and drifts the lifetime) every time
     * an unrelated notification replaces the map. The same Toast is reused
     * when the next queued popup takes over, so re-arm on every change.
     */
    property double deadline: 0
    function arm() {
        if (!notif)
            return;
        deadline = Notifs.expireAt[notif.id] || (Date.now() + 6000);
        if (expiry.running)
            expiry.restart();
    }
    Component.onCompleted: arm()
    onNotifChanged: arm()

    Timer {
        id: expiry
        interval: Math.max(300, root.deadline - Date.now())
        running: root.deadline > 0 && root.live && !root.critical
        onTriggered: Notifs.removePopup(root.notif)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Notifs.activateNotif(root.notif);
            Notifs.removePopup(root.notif);
        }
    }

    Rectangle {
        id: iconTile
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 22 * root.s
        height: 22 * root.s
        radius: 7 * root.s
        color: Theme.tileBg
        border.width: 1
        border.color: root.critical ? Theme.accent : Theme.border

        Image {
            id: toastImg
            anchors.fill: parent
            anchors.margins: root.notif.image ? 0 : 4 * root.s
            source: Notifs.iconFor(root.notif)
            sourceSize.width: 44
            sourceSize.height: 44
            fillMode: Image.PreserveAspectCrop
            smooth: true
            visible: source.toString().length > 0
        }

        Rectangle {
            anchors.centerIn: parent
            visible: !toastImg.visible
            width: 6 * root.s
            height: 6 * root.s
            radius: 2 * root.s
            rotation: 45
            color: root.critical ? Theme.accent : Theme.accentDark
        }
    }

    Text {
        id: summary
        anchors.left: iconTile.right
        anchors.leftMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        width: root.summaryW
        text: root.notif.summary.length ? root.notif.summary
            : ((root.notif.appName && root.notif.appName.length) ? root.notif.appName : "System")
        color: root.critical ? Theme.accent : Theme.text
        font.family: Theme.font
        font.pixelSize: 12.5 * root.s
        font.weight: Font.DemiBold
        maximumLineCount: 1
        elide: Text.ElideRight
    }

    Text {
        id: body
        anchors.left: summary.right
        anchors.leftMargin: root.gap
        anchors.right: actions.left
        anchors.rightMargin: root.acts.length ? root.gap : 0
        anchors.verticalCenter: parent.verticalCenter
        text: root.notif.body.replace(/\s+/g, " ")
        color: Theme.textDim
        font.family: Theme.font
        font.pixelSize: 11.5 * root.s
        maximumLineCount: 1
        elide: Text.ElideRight
        textFormat: Text.PlainText
    }

    Row {
        id: actions
        anchors.right: moreText.left
        anchors.rightMargin: root.gap
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6 * root.s

        Repeater {
            model: root.acts

            Rectangle {
                id: actPill
                required property var modelData
                required property int index

                height: 20 * root.s
                width: actText.implicitWidth + 16 * root.s
                radius: 999
                color: Theme.tileBg
                border.width: 1
                border.color: Theme.border

                Text {
                    id: actText
                    anchors.centerIn: parent
                    text: actPill.modelData.text
                    color: actPill.index === 0 ? Theme.accent : Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: 10 * root.s
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        actPill.modelData.invoke();
                        if (actPill.modelData.identifier === "default")
                            Notifs.raiseWindow(root.notif);
                        Notifs.removePopup(root.notif);
                    }
                }
            }
        }
    }

    Text {
        id: moreText
        anchors.right: dismiss.left
        anchors.rightMargin: root.more > 0 ? root.gap : 0
        anchors.verticalCenter: parent.verticalCenter
        text: root.more > 0 ? "+" + root.more : ""
        color: Theme.textDim
        font.family: Theme.font
        font.pixelSize: 10.5 * root.s
        font.weight: Font.DemiBold
    }

    Icon {
        id: dismiss
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        size: 13 * root.s
        text: Icons.close
        color: dismissArea.containsMouse ? Theme.text : Theme.textDim

        MouseArea {
            id: dismissArea
            anchors.fill: parent
            anchors.margins: -6 * root.s
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Notifs.removePopup(root.notif)
        }
    }
}
