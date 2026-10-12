import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import "../services"

/**
 * Background of a notch hanging from the top edge: gradient fill, border on
 * the sides and bottom only, concave "ears" joining the screen, an inner
 * sheen along the bottom and a drop shadow. Fill its parent with it; the
 * ears reach `ear` beyond either side.
 */
Item {
    id: root

    property real s: 1
    property real radius: 18 * s
    readonly property real ear: 16 * s

    /**
     * SVG outline: `b` bottom corners, `e` ears; the body spans x = e .. e + w.
     * The top edge runs along the screen, so the border (`closed` false)
     * leaves it out.
     */
    function outline(w, h, b, e, closed) {
        const r = (v) => Math.round(v * 100) / 100;
        b = Math.max(0, Math.min(b, h / 2, w / 2));
        e = Math.max(0, Math.min(e, h - b));
        const x0 = e, x1 = e + w;
        let p = `M 0 0 A ${r(e)} ${r(e)} 0 0 1 ${r(x0)} ${r(e)} L ${r(x0)} ${r(h - b)} `;
        if (b > 0.01) p += `A ${r(b)} ${r(b)} 0 0 0 ${r(x0 + b)} ${r(h)} `;
        p += `L ${r(x1 - b)} ${r(h)} `;
        if (b > 0.01) p += `A ${r(b)} ${r(b)} 0 0 0 ${r(x1)} ${r(h - b)} `;
        p += `L ${r(x1)} ${r(e)} A ${r(e)} ${r(e)} 0 0 1 ${r(x1 + e)} 0`;
        return closed ? p + " Z" : p;
    }

    Item {
        x: -root.ear
        width: root.width + 2 * root.ear
        height: root.height

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.shadow
            shadowBlur: 0.7
            shadowVerticalOffset: 3 * root.s
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillGradient: LinearGradient {
                    x1: 0; y1: 0
                    x2: 0; y2: root.height
                    GradientStop { position: 0.0; color: Qt.alpha(Theme.cardTop, Flags.pillOpacity) }
                    GradientStop { position: 1.0; color: Qt.alpha(Theme.cardBot, Flags.pillOpacity) }
                }
                PathSvg { path: root.outline(root.width, root.height, root.radius, root.ear, true) }
            }

            ShapePath {
                strokeColor: Theme.border
                strokeWidth: 1
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap
                joinStyle: ShapePath.RoundJoin
                PathSvg { path: root.outline(root.width, root.height, root.radius, root.ear, false) }
            }
        }

        /** Inner sheen along the bottom edge. */
        Rectangle {
            x: root.ear + root.radius * 0.9
            width: Math.max(0, root.width - root.radius * 1.8)
            y: root.height - 2
            height: 1
            color: Theme.sheen
        }
    }
}
