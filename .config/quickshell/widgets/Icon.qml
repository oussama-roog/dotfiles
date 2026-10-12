import QtQuick
import "../services"

/**
 * Phosphor icon glyph: `Icon { text: Icons.cpu; size: 16 }`. The item is a
 * `size` square with the glyph centred in it.
 */
Text {
    property real size: 16

    width: size
    height: size
    font.family: Icons.font
    font.pixelSize: size
    color: Theme.icon
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color { ColorAnimation { duration: Motion.fast } }
}
