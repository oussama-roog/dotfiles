import QtQuick
import QtQuick.Controls
import "../services"

/**
 * Search row shared by the list surfaces: icon (or kanji when Flags.showGlyphs),
 * text field, a counter, and an optional slot on the right for a button.
 * Up/Down emit `moved`, Enter `accepted`, Escape `dismissed`; every other key
 * goes through `keyPressed` first so a surface can claim shortcuts.
 */
Item {
    id: root

    property real s: 1
    property string kanji: ""
    property string icon: "search"
    property string placeholder: ""
    property string counterText: ""

    readonly property alias input: field
    property alias text: field.text
    default property alias rightContent: rightSlot.data

    signal moved(int delta)
    signal accepted()
    signal dismissed()
    signal keyPressed(var event)

    height: 30 * s

    Text {
        id: glyph
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        visible: Flags.showGlyphs
        width: Flags.showGlyphs ? implicitWidth : 0
        text: root.kanji
        color: Theme.textDim
        font.family: Theme.fontJp
        font.weight: Font.Medium
        font.pixelSize: 16 * root.s
    }

    GlyphIcon {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        visible: !Flags.showGlyphs
        width: !Flags.showGlyphs ? 14 * root.s : 0
        name: root.icon
        color: Theme.textDim
        stroke: 1.8
    }

    TextField {
        id: field
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: Flags.showGlyphs ? glyph.right : parent.left
        anchors.leftMargin: Flags.showGlyphs ? 10 * root.s : (22 * root.s)
        anchors.right: counter.left
        anchors.rightMargin: 10 * root.s
        background: null
        padding: 0
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 15 * root.s
        placeholderText: root.placeholder
        placeholderTextColor: Theme.textFaint
        selectByMouse: true
        selectionColor: Theme.accentDark
        cursorDelegate: Item {}
        Keys.onUpPressed: root.moved(-1)
        Keys.onDownPressed: root.moved(1)
        Keys.onPressed: (e) => {
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

    Rectangle {
        anchors.left: field.left
        anchors.right: field.right
        anchors.top: field.bottom
        anchors.topMargin: 2 * root.s
        height: 1
        color: Theme.textFaint
        opacity: field.activeFocus ? 0.7 : 0
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
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
        width: childrenRect.width
        height: parent.height
    }
}
