pragma Singleton
import QtQuick
import Quickshell

/**
 * Animation timings, modelled on Ambxst: things that open or grow ease out
 * with a slight overshoot (OutBack 1.2), things that close or shrink ease out
 * with OutQuart. Everything speeds up under Flags.reduceMotion.
 */
Singleton {
    readonly property real mult: Flags.reduceMotion ? 0.4 : 1
    readonly property int fast:     Math.round(150 * mult)
    readonly property int standard: Math.round(300 * mult)
    readonly property int morph:    Math.round(320 * mult)
    readonly property int heat:     Math.round(1100 * mult)

    readonly property int easeStandard: Easing.OutQuart
    readonly property int easeOpen:     Easing.OutBack
    readonly property int easeClose:    Easing.OutQuart
    readonly property real overshoot:   1.2
}
