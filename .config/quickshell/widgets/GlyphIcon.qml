import QtQuick
import QtQuick.Shapes
import "../services"

/**
 * Self-contained vector glyph drawn from baked SVG path data, so the pill never
 * depends on the system icon theme or external asset files. Set `name` to pick a
 * glyph, `color` to tint it; stroked glyphs use `stroke` width, filled glyphs
 * (media transport) paint solid. Paths live in a 24x24 space and scale to the
 * item's size. Each glyph's actual bounding box is centred within the item on
 * both axes, so glyphs with differing path extents share one optical baseline.
 */
Item {
    id: root

    property string name: ""
    property color color: Theme.icon
    property real stroke: 1.8

    readonly property real u: Math.min(width, height) / 24

    readonly property var glyphs: ({
        "bolt": { d: "M13 2 4 13.5h6.5L11 22l9-11.5h-6.5z", fill: false },
        "check": { d: "M20 6 9 17l-5-5", fill: false },
        "chevron-down": { d: "M6 10l6 6 6-6", fill: false },
        "chevron-right": { d: "M10 6l6 6-6 6", fill: false },
        "clipboard": { d: "M9 4h6v3H9z M9 5.5H6.5A1.5 1.5 0 0 0 5 7v12.5A1.5 1.5 0 0 0 6.5 21h11a1.5 1.5 0 0 0 1.5-1.5V7a1.5 1.5 0 0 0-1.5-1.5H15", fill: false },
        "close": { d: "M6 6l12 12 M18 6l-12 12", fill: false },
        "cpu": { d: "M6 4h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z M9 9h6v6H9z M9 2v2 M15 2v2 M9 20v2 M15 20v2 M2 9h2 M2 15h2 M20 9h2 M20 15h2", fill: false },
        "globe": { d: "M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18z M3 12h18 M12 3c2.5 2.5 3.8 5.5 3.8 9s-1.3 6.5-3.8 9c-2.5-2.5-3.8-5.5-3.8-9s1.3-6.5 3.8-9z", fill: false },
        "inbox": { d: "M6 16v-5a6 6 0 0 1 12 0v5 M4 16h16 M10.5 20a1.8 1.8 0 0 0 3 0", fill: false },
        "lock": { d: "M6 10h12a1.5 1.5 0 0 1 1.5 1.5v6a1.5 1.5 0 0 1-1.5 1.5H6a1.5 1.5 0 0 1-1.5-1.5v-6A1.5 1.5 0 0 1 6 10z M8.5 10V7a3.5 3.5 0 0 1 7 0v3", fill: false },
        "logout": { d: "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4 M16 17l5-5-5-5 M21 12H9", fill: false },
        "memory": { d: "M4 6h16a2 2 0 0 1 2 2v1.1a2 2 0 0 0 0 3.8V16a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2v-3.1a2 2 0 0 0 0-3.8V8a2 2 0 0 1 2-2z M2 14h20 M6 18v-3 M10 18v-3 M14 18v-3 M18 18v-3 M8 11V9 M12 11V9 M16 11V9", fill: false },
        "music": { d: "M9 18V5l12-2v13 M9 18a3 3 0 1 1-6 0 3 3 0 0 1 6 0z M21 16a3 3 0 1 1-6 0 3 3 0 0 1 6 0z", fill: false },
        "palette": { d: "M12 2a10 10 0 1 0 0 20c1.1 0 2-.9 2-2v-1a2 2 0 0 1 2-2h1c1.1 0 2-.9 2-2a10 10 0 0 0-9-11z M7.5 11.5a1 1 0 1 0 .01 0 M9.5 7.5a1 1 0 1 0 .01 0 M14 6.5a1 1 0 1 0 .01 0 M17 10.5a1 1 0 1 0 .01 0", fill: false },
        "pause": { d: "M8 5h3v14H8z M13 5h3v14h-3z", fill: true },
        "play": { d: "M7 5l12 7-12 7z", fill: true },
        "reboot": { d: "M21 12a9 9 0 1 1-2.6-6.4 M21 3v5h-5", fill: false },
        "search": { d: "M11 4a7 7 0 1 0 0 14a7 7 0 1 0 0-14z M20 20l-4-4", fill: false },
        "shutdown": { d: "M12 3v9 M7.8 6.3a8 8 0 1 0 8.4 0", fill: false },
        "sparkles": { d: "M12 3l1.7 5.1 5.1 1.7-5.1 1.7L12 16.6l-1.7-5.1-5.1-1.7 5.1-1.7z M5 15.5l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7z", fill: false },
        "speaker": { d: "M4 9v6h4l5 4V5L8 9z M16 9.5a3 3 0 0 1 0 5 M18.5 7.5a6 6 0 0 1 0 9", fill: false },
        "speaker-off": { d: "M4 9v6h4l5 4V5L8 9z M16.2 9.8l4.4 4.4 M20.6 9.8l-4.4 4.4", fill: false },
        "sun": { d: "M16 12a4 4 0 1 0-8 0a4 4 0 1 0 8 0 M12 2v2 M12 20v2 M4.2 4.2l1.4 1.4 M18.4 18.4l1.4 1.4 M2 12h2 M20 12h2 M4.2 19.8l1.4-1.4 M18.4 5.6l1.4-1.4", fill: false },
        "suspend": { d: "M21 12.8A9 9 0 1 1 11.2 3 7 7 0 0 0 21 12.8z", fill: false },
        "trash": { d: "M3 6h18 M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6 M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2 M10 11v6 M14 11v6", fill: false },
        "video": { d: "M3 7.5a1.5 1.5 0 0 1 1.5-1.5h9A1.5 1.5 0 0 1 15 7.5v9A1.5 1.5 0 0 1 13.5 18h-9A1.5 1.5 0 0 1 3 16.5z M15 10l6-3v10l-6-3z", fill: false }
    })

    readonly property var g: glyphs[name] !== undefined ? glyphs[name] : ({ d: "", fill: false })

    Shape {
        id: glyph

        width: 24
        height: 24
        scale: root.u
        transformOrigin: Item.TopLeft
        x: glyph.boundingRect.width > 0
           ? root.width / 2 - (glyph.boundingRect.x + glyph.boundingRect.width / 2) * root.u
           : (root.width - 24 * root.u) / 2
        y: glyph.boundingRect.height > 0
           ? root.height / 2 - (glyph.boundingRect.y + glyph.boundingRect.height / 2) * root.u
           : (root.height - 24 * root.u) / 2
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.g.fill ? "transparent" : root.color
            fillColor: root.g.fill ? root.color : "transparent"
            strokeWidth: root.stroke
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.g.d }
        }
    }
}
