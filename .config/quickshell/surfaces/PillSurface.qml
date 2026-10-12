import QtQuick
import QtQuick.Effects
import "../services"

/**
 * Base for every pill surface. Pill declares each one with `host: pill` and a
 * `name`; the surface is open while `host.surface === name`, fills the pill
 * inset by its own `mTop`/`mLeft`/`mRight`/`mBottom` margins, and fades in as
 * the pill finishes morphing to its size. `requestClose()` closes the pill.
 * Like Ambxst's notch views it also scales up with a slight overshoot and
 * sharpens from a blur as it opens.
 */
Item {
    id: surface

    required property Item host
    required property string name

    readonly property real s: host.s
    readonly property bool open: host.surface === name
    readonly property real morphCloseness: host.morphCloseness

    property real mTop: 0
    property real mLeft: 0
    property real mRight: 0
    property real mBottom: 0

    function requestClose() {
        host.requestClose();
    }

    /**
     * Fade in with the morph only on the first open; once settled, a size change
     * inside the open surface (e.g. the inbox growing) must not dim it again.
     */
    property bool settled: false
    onOpenChanged: {
        if (open)
            unblur.restart();
        else
            settled = false;
    }
    onMorphClosenessChanged: if (open && morphCloseness > 0.92) settled = true

    anchors.fill: parent
    anchors.topMargin: mTop * s
    anchors.leftMargin: mLeft * s
    anchors.rightMargin: mRight * s
    anchors.bottomMargin: mBottom * s

    enabled: open
    opacity: open ? (settled ? 1 : Math.pow(morphCloseness, 1.3)) : 0
    visible: opacity > 0.01

    Behavior on opacity {
        NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard }
    }

    scale: open ? 1 : 0.86
    Behavior on scale {
        NumberAnimation {
            duration: Motion.morph
            easing.type: surface.open ? Motion.easeOpen : Motion.easeClose
            easing.overshoot: Motion.overshoot
        }
    }

    property real blur: 0
    NumberAnimation {
        id: unblur
        target: surface
        property: "blur"
        from: 1
        to: 0
        duration: Motion.morph
        easing.type: Easing.OutQuart
    }
    layer.enabled: blur > 0.01
    layer.effect: MultiEffect {
        blurEnabled: true
        blurMax: 32
        blur: surface.blur
    }
}
