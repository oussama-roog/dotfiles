import QtQuick

/**
 * Spinning open ring (the circle-notch shape) for working agents, in each
 * agent's own colour: one colour fills the arc, two split it in halves
 * (Claude orange and Antigravity blue), and so on.
 */
Item {
    id: root

    property real size: 24
    /** One colour per working agent. */
    property var colors: []
    property bool spinning: true
    property real thickness: Math.max(1.5, size * 0.12)

    width: size
    height: size

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var n = root.colors.length;
            if (n === 0)
                return;
            var r = (Math.min(width, height) - root.thickness) / 2;
            var gap = 0.12;
            // Three quarters of a turn, like the circle-notch icon.
            var sweep = Math.PI * 1.5 / n;
            ctx.lineWidth = root.thickness;
            ctx.lineCap = "round";
            for (var i = 0; i < n; i++) {
                var a = -Math.PI / 2 + i * sweep;
                ctx.strokeStyle = root.colors[i];
                ctx.beginPath();
                ctx.arc(width / 2, height / 2, r, a + (n > 1 ? gap / 2 : 0), a + sweep - (n > 1 ? gap / 2 : 0), false);
                ctx.stroke();
            }
        }

        RotationAnimation on rotation {
            running: root.spinning && root.visible
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 1100
        }
    }

    onColorsChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
}
