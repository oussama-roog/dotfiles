pragma Singleton
import QtQuick
import Quickshell

/** Animation durations and curves; everything speeds up under Flags.reduceMotion. */
Singleton {
    readonly property real mult: Flags.reduceMotion ? 0.4 : 1
    readonly property int fast:     Math.round(140 * mult)
    readonly property int standard: Math.round(300 * mult)
    readonly property int morph:    Math.round(420 * mult)
    readonly property int heat:     Math.round(1100 * mult)
    readonly property int easeStandard: Easing.OutCubic
    readonly property int easeMorph:    Easing.BezierSpline

    /** Liquid morph curve, cubic-bezier(0.16, 1, 0.3, 1); use with easeMorph. */
    readonly property var morphCurve: [0.16, 1, 0.3, 1, 1, 1]
    readonly property real rTile: 13
}
