pragma ComponentBehavior: Bound

import QtQuick
import "Singletons"

/**
 * Simplified SETTINGS surface for Niri — shows only the toggles that are
 * meaningful without the removed Hyprland-specific sub-surfaces.
 */
SettingsSurface {
    id: root

    implicitHeight: content.implicitHeight

    rows: [
        { item: dndRow,       kind: "toggle" },
        { item: keepAwakeRow, kind: "toggle" },
        { item: time12hRow,   kind: "toggle" },
        { item: secondsRow,   kind: "toggle" },
        { item: glyphsRow,    kind: "toggle" }
    ]

    Column {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        SettingsHeader {
            s: root.s
            glyph: "cog"
            title: "SETTINGS"
        }

        Text {
            topPadding: 14 * root.s
            bottomPadding: 2 * root.s
            leftPadding: 12 * root.s
            text: "Notifications"
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 8.5 * root.s
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.2 * root.s
        }

        SettingsRow {
            id: dndRow
            surface: root
            icon: "bell-off"
            name: "Do Not Disturb"
            sub: "Silence incoming notifications"

            SettingsSeg {
                s: root.s
                options: [{ label: "On", value: true }, { label: "Off", value: false }]
                value: Flags.dnd
                onPicked: (val) => Flags.dnd = val
            }
        }

        Text {
            topPadding: 14 * root.s
            bottomPadding: 2 * root.s
            leftPadding: 12 * root.s
            text: "System"
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 8.5 * root.s
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.2 * root.s
        }

        SettingsRow {
            id: keepAwakeRow
            surface: root
            icon: "eye"
            name: "Keep Awake"
            sub: "Prevent idle / screen off"

            SettingsSeg {
                s: root.s
                options: [{ label: "On", value: true }, { label: "Off", value: false }]
                value: Flags.keepAwake
                onPicked: (val) => Flags.keepAwake = val
            }
        }

        Text {
            topPadding: 14 * root.s
            bottomPadding: 2 * root.s
            leftPadding: 12 * root.s
            text: "Clock"
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 8.5 * root.s
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.2 * root.s
        }

        SettingsRow {
            id: time12hRow
            surface: root
            icon: "clock"
            name: "12-Hour Clock"
            sub: "Display time in 12-hour format"

            SettingsSeg {
                s: root.s
                options: [{ label: "On", value: true }, { label: "Off", value: false }]
                value: Flags.time12h
                onPicked: (val) => Flags.time12h = val
            }
        }

        SettingsRow {
            id: secondsRow
            surface: root
            icon: "clock"
            name: "Show Seconds"
            sub: "Display seconds in the clock"

            SettingsSeg {
                s: root.s
                options: [{ label: "On", value: true }, { label: "Off", value: false }]
                value: Flags.clockSeconds
                onPicked: (val) => Flags.clockSeconds = val
            }
        }

        Text {
            topPadding: 14 * root.s
            bottomPadding: 2 * root.s
            leftPadding: 12 * root.s
            text: "Appearance"
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 8.5 * root.s
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.2 * root.s
        }

        SettingsRow {
            id: glyphsRow
            surface: root
            icon: "sparkles"
            name: "Show Glyphs"
            sub: "Show kanji glyphs in surfaces"
            last: true

            SettingsSeg {
                s: root.s
                options: [{ label: "On", value: true }, { label: "Off", value: false }]
                value: Flags.showGlyphs
                onPicked: (val) => Flags.showGlyphs = val
            }
        }
    }
}
