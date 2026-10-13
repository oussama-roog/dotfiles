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

    // Hover peek
    readonly property string batteryHigh: "\ue0c2"
    readonly property string batteryMedium: "\ue0c6"
    readonly property string batteryLow: "\ue0c4"

    // Launcher modes and actions
    readonly property string image: "\ue2ca"
    readonly property string camera: "\ue10e"
    readonly property string keyboard: "\ue2d8"
    readonly property string clipboardText: "\ue198"
    readonly property string equals: "\ue21c"
    readonly property string smiley: "\ue436"
    readonly property string bellSlash: "\ue0d4"
    readonly property string actions: "\uea84"
    readonly property string reload: "\ue036"

    // Agents
    readonly property string checkCircle: "\ue184"
    readonly property string warning: "\ue4e2"
    readonly property string question: "\ue3e8"
    readonly property string circleNotch: "\ueb44"
    readonly property string terminal: "\ueae8"

    // Tasks
    readonly property string listChecks: ""
    readonly property string circle: ""
    readonly property string plus: ""
    readonly property string pencil: ""
    readonly property string notePencil: ""
    readonly property string sliders: ""
    readonly property string calendar: ""
    readonly property string calendarCheck: ""
    readonly property string tag: ""
    readonly property string folder: ""
    readonly property string flag: ""
    readonly property string undo: ""
    readonly property string clock: ""
    readonly property string hourglass: ""

    // OSD
    readonly property string speaker: ""
    readonly property string speakerOff: ""
    readonly property string sun: ""
    readonly property string lightning: ""
    readonly property string music: ""
    readonly property string play: ""
    readonly property string pause: ""
}
