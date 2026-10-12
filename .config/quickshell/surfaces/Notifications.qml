pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../services"
import "../widgets"

/**
 * Notification inbox: notifications grouped by app (criticals pinned on top),
 * click a row to open its app, hover to dismiss, CLEAR wipes everything.
 * Opening marks all notifications seen after a short beat so the unread dots
 * register first.
 */
PillSurface {
    id: root

    mTop: 13
    mLeft: 16
    mRight: 16
    mBottom: 13


    implicitHeight: mainCol.implicitHeight

    onOpenChanged: {
        if (open)
            seenTimer.restart();
        else
            seenTimer.stop();
    }

    Timer {
        id: seenTimer
        interval: 600
        repeat: false
        onTriggered: Notifs.markAllSeen()
    }

    /**
     * Ember mark: a small flame-glow dot over a soft halo, the unread marker
     * shared by the header badge and unread notification titles.
     */
    component Ember: Item {
        id: ember
        property real size: 4 * root.s

        width: size * 2.2
        height: size * 2.2

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            color: Theme.accent
            opacity: 0.22
        }

        Rectangle {
            anchors.centerIn: parent
            width: ember.size
            height: ember.size
            radius: width / 2
            color: Theme.accent
        }
    }

    /**
     * Single inbox entry: icon tile or diamond, body text, ×N coalesce badge,
     * age label that cross-fades into a dismiss glyph on hover. Critical
     * entries gain an accent left hairline and brighter text.
     */
    component NotifRow: Rectangle {
        id: nrow

        required property var entry
        property bool critical: false
        readonly property var n: entry.n

        width: parent ? parent.width : 0
        height: 26 * root.s
        radius: 7 * root.s
        color: nrowHover.hovered ? Theme.frameBg : "transparent"

        HoverHandler {
            id: nrowHover
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Notifs.activateEntry(nrow.entry);
                root.requestClose();
            }
        }

        Rectangle {
            visible: nrow.critical
            anchors.left: parent.left
            anchors.leftMargin: 1 * root.s
            anchors.verticalCenter: parent.verticalCenter
            width: 2 * root.s
            height: parent.height - 10 * root.s
            radius: 999
            color: Theme.accentDark
        }

        Rectangle {
            id: nrowTile
            anchors.left: parent.left
            anchors.leftMargin: 8 * root.s
            anchors.verticalCenter: parent.verticalCenter
            width: 16 * root.s
            height: 16 * root.s
            radius: 5 * root.s
            color: Theme.tileBg
            border.width: 1
            border.color: Theme.border

            Image {
                id: nrowImg
                anchors.fill: parent
                anchors.margins: nrow.n.image ? 0 : 2 * root.s
                source: Notifs.iconFor(nrow.n)
                sourceSize.width: 40
                sourceSize.height: 40
                fillMode: Image.PreserveAspectCrop
                smooth: true
                visible: source.toString().length > 0
            }

            Rectangle {
                anchors.centerIn: parent
                visible: !nrowImg.visible
                width: 5 * root.s
                height: 5 * root.s
                radius: 1.5 * root.s
                rotation: 45
                color: nrow.critical ? Theme.accent : Theme.accentDark
            }
        }

        Text {
            anchors.left: nrowTile.right
            anchors.leftMargin: 8 * root.s
            anchors.right: nrowRight.left
            anchors.rightMargin: 8 * root.s
            anchors.verticalCenter: parent.verticalCenter
            text: nrow.n.body.length > 0 ? nrow.n.body : nrow.n.summary
            color: nrow.critical ? Theme.text : Theme.textSubtle
            font.family: Theme.font
            font.pixelSize: 10.5 * root.s
            font.weight: nrow.critical ? Font.DemiBold : Font.Medium
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
        }

        Row {
            id: nrowRight
            anchors.right: parent.right
            anchors.rightMargin: 8 * root.s
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6 * root.s

            Text {
                visible: nrow.entry.count > 1
                anchors.verticalCenter: parent.verticalCenter
                text: "×" + nrow.entry.count
                color: nrow.critical ? Theme.accent : Theme.accentDim
                font.family: Theme.font
                font.pixelSize: 9 * root.s
                font.weight: Font.Bold
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(nrowAge.implicitWidth, nrowX.implicitWidth)
                height: Math.max(nrowAge.implicitHeight, nrowX.implicitHeight)

                Text {
                    id: nrowAge
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: nrowHover.hovered ? 0 : 1
                    text: Notifs.ageLabel(nrow.n)
                    color: Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 9 * root.s
                    Behavior on opacity { NumberAnimation { duration: Motion.fast } }
                }

                Icon {
                    id: nrowX
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    size: 12 * root.s
                    opacity: nrowHover.hovered ? 1 : 0
                    text: Icons.close
                    color: nrowXArea.containsMouse ? Theme.text : Theme.textDim
                    Behavior on opacity { NumberAnimation { duration: Motion.fast } }

                    MouseArea {
                        id: nrowXArea
                        anchors.fill: parent
                        anchors.margins: -6 * root.s
                        enabled: nrowHover.hovered
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.dismissEntry(nrow.entry)
                    }
                }
            }
        }
    }

    Item {
        id: mainView
        anchors.fill: parent
        enabled: root.open

        Column {
            id: mainCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4 * root.s

            Item {
                width: parent.width
                height: 24 * root.s

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8 * root.s

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Flags.showGlyphs
                        text: "報"
                        color: Theme.text
                        font.family: Theme.fontJp
                        font.weight: Font.Medium
                        font.pixelSize: 16 * root.s
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "INBOX"
                        color: Theme.textSubtle
                        font.family: Theme.font
                        font.pixelSize: 10 * root.s
                        font.weight: Font.DemiBold
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 1.6 * root.s
                    }
                }

                /** The notification dot docks its bell here (see shell.qml). */
                readonly property real bellSlot: 24 * root.s

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: parent.bellSlot + 6 * root.s
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6 * root.s
                    visible: Notifs.unread > 0

                    Ember {
                        id: headerEmber
                        anchors.verticalCenter: parent.verticalCenter
                        size: 6 * root.s

                        SequentialAnimation on opacity {
                            running: headerEmber.visible
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.55; to: 1; duration: 1200; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1; to: 0.55; duration: 1200; easing.type: Easing.InOutSine }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Notifs.unread + " NEU"
                        color: Theme.textDim
                        font.family: Theme.font
                        font.pixelSize: 9.5 * root.s
                        font.weight: Font.Bold
                        font.letterSpacing: 1.4 * root.s
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.hair
            }

            Item {
                width: parent.width
                height: 20 * root.s

                Row {
                    id: clearRow
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Notifs.count > 0
                    spacing: 4 * root.s

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "払"
                        color: clearArea.containsMouse ? Theme.accent : Theme.accentDim
                        font.family: Theme.fontJp
                        font.pixelSize: 9 * root.s
                        font.weight: Font.Bold
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "CLEAR"
                        color: clearArea.containsMouse ? Theme.accent : Theme.accentDim
                        font.family: Theme.font
                        font.pixelSize: 9 * root.s
                        font.weight: Font.Bold
                        font.letterSpacing: 1.4 * root.s
                    }
                }

                MouseArea {
                    id: clearArea
                    anchors.fill: clearRow
                    anchors.margins: -5 * root.s
                    visible: Notifs.count > 0
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.clearAll()
                }
            }

            Item {
                visible: Notifs.count > 0
                width: parent.width
                height: notifFlick.height

                Flickable {
                    id: notifFlick
                    width: parent.width
                    height: Math.min(notifCol.implicitHeight, 320 * root.s)
                    contentHeight: notifCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    onContentHeightChanged: returnToBounds()

                    Column {
                        id: notifCol
                        width: notifFlick.width
                        spacing: 6 * root.s

                        Repeater {
                            model: Notifs.groups

                            Column {
                                id: group
                                required property var modelData
                                readonly property bool expanded: Notifs.expandedApps[modelData.app] === true
                                width: notifCol.width
                                spacing: 2 * root.s

                                Repeater {
                                    model: group.modelData.criticals

                                    NotifRow {
                                        required property var modelData
                                        entry: modelData
                                        critical: true
                                    }
                                }

                                Rectangle {
                                    id: groupHead
                                    width: parent.width
                                    height: 32 * root.s
                                    radius: 8 * root.s
                                    color: headHover.hovered ? Theme.frameBg : "transparent"

                                    HoverHandler {
                                        id: headHover
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Notifs.toggleExpanded(group.modelData.app)
                                    }

                                    Rectangle {
                                        id: headTile
                                        anchors.left: parent.left
                                        anchors.leftMargin: 6 * root.s
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 20 * root.s
                                        height: 20 * root.s
                                        radius: 6 * root.s
                                        color: Theme.tileBg
                                        border.width: 1
                                        border.color: Theme.border

                                        Image {
                                            id: headImg
                                            anchors.fill: parent
                                            anchors.margins: group.modelData.newest.image ? 0 : 3 * root.s
                                            source: Notifs.iconFor(group.modelData.newest)
                                            sourceSize.width: 40
                                            sourceSize.height: 40
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true
                                            visible: source.toString().length > 0
                                        }

                                        Rectangle {
                                            anchors.centerIn: parent
                                            visible: !headImg.visible
                                            width: 6 * root.s
                                            height: 6 * root.s
                                            radius: 2 * root.s
                                            rotation: 45
                                            color: Theme.accentDark
                                        }
                                    }

                                    Text {
                                        id: headName
                                        anchors.left: headTile.right
                                        anchors.leftMargin: 8 * root.s
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: Math.min(implicitWidth, 110 * root.s)
                                        text: group.modelData.app
                                        color: Theme.textSubtle
                                        font.family: Theme.font
                                        font.pixelSize: 9 * root.s
                                        font.weight: Font.Bold
                                        font.capitalization: Font.AllUppercase
                                        font.letterSpacing: 1.2 * root.s
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: headCount
                                        anchors.left: headName.right
                                        anchors.leftMargin: 5 * root.s
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "· " + group.modelData.count
                                        color: Theme.textFaint
                                        font.family: Theme.font
                                        font.pixelSize: 9 * root.s
                                    }

                                    Text {
                                        anchors.left: headCount.right
                                        anchors.leftMargin: 8 * root.s
                                        anchors.right: headX.left
                                        anchors.rightMargin: 8 * root.s
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: group.modelData.preview.body.length > 0
                                            ? group.modelData.preview.body
                                            : group.modelData.preview.summary
                                        color: Theme.textDim
                                        font.family: Theme.font
                                        font.pixelSize: 10 * root.s
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        textFormat: Text.PlainText
                                    }

                                    Icon {
                                        id: headChev
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8 * root.s
                                        anchors.verticalCenter: parent.verticalCenter
                                        size: 12 * root.s
                                        text: group.expanded ? Icons.caretDown : Icons.caretRight
                                        color: Theme.textFaint
                                    }

                                    Icon {
                                        id: headX
                                        anchors.right: headChev.left
                                        anchors.rightMargin: 7 * root.s
                                        anchors.verticalCenter: parent.verticalCenter
                                        size: 12 * root.s
                                        opacity: headHover.hovered ? 1 : 0
                                        text: Icons.close
                                        color: headXArea.containsMouse ? Theme.text : Theme.textDim
                                        Behavior on opacity { NumberAnimation { duration: Motion.fast } }

                                        MouseArea {
                                            id: headXArea
                                            anchors.fill: parent
                                            anchors.margins: -6 * root.s
                                            enabled: headHover.hovered
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Notifs.dismissApp(group.modelData.app)
                                        }
                                    }
                                }

                                Column {
                                    visible: group.expanded
                                    width: parent.width
                                    spacing: 2 * root.s

                                    Repeater {
                                        model: group.expanded ? group.modelData.entries : []

                                        NotifRow {
                                            required property var modelData
                                            entry: modelData
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                WheelScroller {
                    anchors.fill: parent
                    s: root.s
                    flick: notifFlick
                }
            }

            Column {
                visible: Notifs.count === 0
                width: parent.width
                topPadding: 14 * root.s
                bottomPadding: 14 * root.s
                spacing: 4 * root.s

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: Flags.showGlyphs
                    text: "静"
                    color: Theme.ghost
                    opacity: 0.55
                    font.family: Theme.fontJp
                    font.weight: Font.Medium
                    font.pixelSize: 32 * root.s
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Flags.showGlyphs ? "SILENCE" : "No notifications to display"
                    color: Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 9 * root.s
                    font.weight: Font.Bold
                    font.letterSpacing: Flags.showGlyphs ? 2.2 * root.s : 0.8 * root.s
                }
            }
        }
    }
}
