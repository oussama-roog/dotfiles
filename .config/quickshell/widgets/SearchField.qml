import QtQuick
import QtQuick.Controls
import "../services"

/**
 * Search row shared by the list surfaces, styled after Ambxst's search input:
 * a filled rounded field with an accent icon (or kanji when Flags.showGlyphs),
 * the text, a counter, and an optional slot on the right for a button.
 * Up/Down (or Ctrl+K/Ctrl+J, vim style) emit `moved`, Enter `accepted`,
 * Escape `dismissed`; every other key goes through `keyPressed` first so a
 * surface can claim shortcuts.
 */
Item {
    id: root

    property real s: 1
    property string kanji: ""
    property string icon: Icons.search
    property string placeholder: ""
    property string counterText: ""

    readonly property alias input: field
    property alias text: field.text
    default property alias rightContent: rightSlot.data

    signal moved(int delta)
    signal accepted()
    signal dismissed()
    signal keyPressed(var event)

    height: 40 * s

    Rectangle {
        anchors.fill: parent
        radius: 14 * root.s
        color: Theme.frameBg
        border.width: 1
        border.color: field.activeFocus ? Qt.alpha(Theme.accent, 0.35) : Theme.frameBorder
        Behavior on border.color { ColorAnimation { duration: Motion.standard } }
    }

    Item {
        id: lead
        anchors.left: parent.left
        anchors.leftMargin: 12 * root.s
        anchors.verticalCenter: parent.verticalCenter
        width: 18 * root.s
        height: 18 * root.s

        Text {
            anchors.centerIn: parent
            visible: Flags.showGlyphs
            text: root.kanji
            color: Theme.accent
            font.family: Theme.fontJp
            font.weight: Font.Medium
            font.pixelSize: 16 * root.s
        }

        Icon {
            anchors.centerIn: parent
            visible: !Flags.showGlyphs
            size: 18 * root.s
            text: root.icon
            color: Theme.accent
        }
    }

    TextField {
        id: field
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: lead.right
        anchors.leftMargin: 10 * root.s
        anchors.right: counter.left
        anchors.rightMargin: 10 * root.s
        background: null
        padding: 0
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 14 * root.s
        placeholderText: root.placeholder
        placeholderTextColor: Theme.textFaint
        selectByMouse: true
        selectionColor: Theme.accentDark
        selectedTextColor: Theme.onAccent
        cursorDelegate: Rectangle {
            width: 2 * root.s
            radius: 1
            color: Theme.accent
            visible: field.cursorVisible
        }
        Keys.onUpPressed: root.moved(-1)
        Keys.onDownPressed: root.moved(1)
        Keys.onPressed: (e) => {
            if (e.modifiers & Qt.ControlModifier && (e.key === Qt.Key_J || e.key === Qt.Key_K)) {
                root.moved(e.key === Qt.Key_J ? 1 : -1);
                e.accepted = true;
                return;
            }
            root.keyPressed(e);
            if (e.accepted)
                return;
            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                root.accepted();
                e.accepted = true;
            } else if (e.key === Qt.Key_Escape) {
                root.dismissed();
                e.accepted = true;
            }
        }
    }

    Text {
        id: counter
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: rightSlot.left
        anchors.rightMargin: rightSlot.width > 0 ? 10 * root.s : 0
        text: root.counterText
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: 10.5 * root.s
        font.features: { "tnum": 1 }
    }

    Item {
        id: rightSlot
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 14 * root.s
        width: childrenRect.width
        height: parent.height
    }
}
