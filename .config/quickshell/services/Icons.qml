pragma Singleton
import QtQuick
import Quickshell

/**
 * Phosphor-Bold icon glyphs (same icon font as Ambxst). Render them with
 * widgets/Icon.qml: `Icon { text: Icons.cpu }`. The font is installed by
 * modules/home/phosphor-icons.nix.
 */
Singleton {
    readonly property string font: "Phosphor-Bold"

    // Rest bar
    readonly property string cpu: ""
    readonly property string ram: ""

    // Notifications
    readonly property string bell: "\ue0ce"

    // Power
    readonly property string lock: ""
    readonly property string logout: ""
    readonly property string suspend: ""
    readonly property string reboot: ""
    readonly property string shutdown: ""

    // Surfaces
    readonly property string search: ""
    readonly property string globe: ""
    readonly property string palette: ""
    readonly property string shuffle: ""
    readonly property string trash: ""
    readonly property string close: ""
    readonly property string check: ""
    readonly property string caretDown: ""
    readonly property string caretRight: ""

    // Web apps
    readonly property string sparkle: ""
    readonly property string youtube: ""
    readonly property string openai: ""
    readonly property string reddit: ""
    readonly property string xLogo: ""
    readonly property string note: ""
    readonly property string envelope: ""
    readonly property string brain: ""

    // Agents
    readonly property string checkCircle: "\ue184"
    readonly property string warning: "\ue4e2"
    readonly property string question: "\ue3e8"
    readonly property string circleNotch: "\ueb44"
    readonly property string terminal: "\ueae8"

    // OSD
    readonly property string speaker: ""
    readonly property string speakerOff: ""
    readonly property string sun: ""
    readonly property string lightning: ""
    readonly property string music: ""
    readonly property string play: ""
    readonly property string pause: ""
}
