pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Colour and font tokens. Colours come from colors.json next to shell.qml,
 * which scripts/themes/quickshell.sh writes on every theme switch; the file is
 * watched, so the shell recolours live. The defaults below are only used until
 * the file exists.
 */
Singleton {
    id: root

    // Surfaces
    readonly property color tileBg:  c.background
    readonly property color cardTop: c.surface_high
    readonly property color cardBot: c.surface_low
    readonly property color ghost:   c.surface_highest
    readonly property color border:  c.border

    // Text
    readonly property color textBright: c.text_bright
    readonly property color text:       c.text
    readonly property color textSubtle: c.text_subtle
    readonly property color textDim:    c.text_dim
    readonly property color textFaint:  c.text_faint
    readonly property color icon:       c.icon

    // Accent
    readonly property color accent:     c.accent
    readonly property color accentDark: Qt.darker(c.accent, 1.18)
    readonly property color accentDim:  Qt.darker(c.accent, 1.5)
    readonly property color accentDeep: c.accent_container

    // Overlays derived from the text colour
    readonly property color hair:        Qt.alpha(text, 0.13)
    readonly property color sheen:       Qt.alpha(text, 0.07)
    readonly property color frameBg:     Qt.alpha(text, 0.055)
    readonly property color frameBorder: Qt.alpha(text, 0.10)
    readonly property color shadow:      Qt.rgba(0, 0, 0, 0.5)

    readonly property string font: (Flags.uiFont.length > 0 && Qt.fontFamilies().indexOf(Flags.uiFont) >= 0) ? Flags.uiFont : "Inter"
    readonly property string fontJp: "Zen Kaku Gothic New"

    readonly property alias c: adapter

    FileView {
        path: Quickshell.shellPath("colors.json")
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()

        JsonAdapter {
            id: adapter
            property string background: "#211711"
            property string surface_low: "#221813"
            property string surface_high: "#2e231b"
            property string surface_highest: "#594636"
            property string border: "#3a2a22"
            property string text_bright: "#fff6f0"
            property string text: "#e6d6cb"
            property string text_subtle: "#b9a99e"
            property string text_dim: "#8a7d74"
            property string text_faint: "#6f635b"
            property string icon: "#cdbfb4"
            property string accent: "#e0563b"
            property string accent_container: "#a3371f"
        }
    }
}
