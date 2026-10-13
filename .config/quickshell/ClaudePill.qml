pragma ComponentBehavior: Bound

import QtQuick
import "services"
import "widgets"

/**
 * Floating dot left of the notch, the bell's mirror. It always shows the most
 * important thing going on, in this order:
 *
 *   needs you   a Claude session waits on a permission or a question: accent
 *               sparkle with a pulsing halo, and the dot stretches left into a
 *               one-line pill naming the session and what it wants
 *   working     a spinning ring round the sparkle (round equaliser bars when
 *               music plays too), a count when several run
 *   just done   a check for a few seconds, with the reply's first line
 *   media       equaliser bars while something plays
 *   idle        a dim sparkle; the dot never hides
 *
 * Clicking the dot opens the agents centre; clicking the stretched pill jumps
 * to that session's terminal. While the centre is open (`merged`) the dot flies
 * into its header like the bell does; shell.qml positions it from `mergeT`.
 */
Item {
    id: root

    property real s: 1
    property bool merged: false

    signal dotClicked()

    property real mergeT: merged ? 1 : 0
    Behavior on mergeT { NumberAnimation { duration: Motion.morph; easing.type: root.merged ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }
    readonly property real dissolve: Math.max(0, Math.min(1, (mergeT - 0.35) / 0.5))

    readonly property bool mediaPlaying: Players.active !== null && Players.active.isPlaying
    /** Equaliser bars in the middle: media alone, or inside the ring while an agent works. */
    readonly property bool showBars: mode === "media" || (mode === "working" && mediaPlaying)

    /** "attention" | "working" | "done" | "media" | "idle" */
    readonly property string mode: Claude.needsYou ? "attention"
        : Claude.working > 0 ? "working"
        : Claude.justDone ? "done"
        : mediaPlaying ? "media"
        : "idle"

    /** The session the stretched pill speaks for. */
    readonly property var subject: mode === "attention" ? Claude.attention[0]
        : mode === "done" ? Claude.justDone : null
    readonly property bool active: subject !== null && !merged

    readonly property real dotW: 34 * s
    readonly property real pad: 16 * s
    readonly property real bubbleW: active ? Math.max(150 * s, Math.min(bubble.implicitWidth, 380 * s)) + pad + 12 * s : 0

    width: dotW + bubbleW
    height: dotW
    Behavior on width { NumberAnimation { duration: Motion.morph; easing.type: root.active ? Motion.easeOpen : Motion.easeClose; easing.overshoot: Motion.overshoot } }

    DotBody {
        anchors.fill: parent
        s: root.s
        dissolve: root.dissolve
        borderColor: root.mode === "attention" ? Qt.alpha(Theme.accent, 0.55) : Theme.border
    }

    // ─── The dot (right end, next to the notch) ──────────────────────────────
    Item {
        id: dot
        anchors.right: parent.right
        width: root.dotW
        height: root.height

        /** Soft accent halo that breathes while a session waits on you. */
        Rectangle {
            anchors.centerIn: parent
            width: 26 * root.s
            height: width
            radius: width / 2
            color: Theme.accent
            visible: root.mode === "attention"
            opacity: 0
            SequentialAnimation on opacity {
                running: root.mode === "attention"
                loops: Animation.Infinite
                NumberAnimation { from: 0.08; to: 0.30; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.30; to: 0.08; duration: 900; easing.type: Easing.InOutSine }
            }
        }

        /** Spinning ring while a session works. */
        Icon {
            anchors.centerIn: parent
            size: 24 * root.s
            text: Icons.circleNotch
            color: Qt.alpha(Theme.accent, 0.85)
            opacity: root.mode === "working" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Motion.standard } }
            RotationAnimation on rotation {
                running: root.mode === "working"
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 1100
            }
        }

        Icon {
            anchors.centerIn: parent
            size: (root.mode === "working" ? 11 : 15) * root.s
            text: root.mode === "done" ? Icons.checkCircle : Icons.sparkle
            visible: !root.showBars
            color: root.mode === "attention" || root.mode === "done" || dotArea.containsMouse || root.merged ? Theme.accent
                : root.mode === "working" ? Theme.text
                : Theme.textFaint
            Behavior on size { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
        }

        /** Equaliser bars while media plays; smaller inside the spinning ring. */
        EqBars {
            anchors.centerIn: parent
            s: root.s
            visible: root.showBars
            scale: root.mode === "working" ? 0.7 : 1
            color: dotArea.containsMouse ? Theme.accent : root.mode === "working" ? Theme.text : Theme.icon
            Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
        }

        /** Number of running sessions, when more than one. */
        Rectangle {
            x: parent.width / 2 + 4 * root.s
            y: parent.height / 2 - 12 * root.s
            width: Math.max(12 * root.s, countText.implicitWidth + 5 * root.s)
            height: 12 * root.s
            radius: height / 2
            color: Theme.accent
            scale: Claude.running > 1 && !root.merged ? 1 : 0
            Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeOpen; easing.overshoot: Motion.overshoot } }

            Text {
                id: countText
                anchors.centerIn: parent
                text: Claude.running
                color: Theme.onAccent
                font.family: Theme.font
                font.pixelSize: 8 * root.s
                font.weight: Font.Bold
            }
        }

        MouseArea {
            id: dotArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dotClicked()
        }
    }

    Rectangle {
        anchors.right: dot.left
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 16 * root.s
        color: Theme.hair
        opacity: bubble.opacity
    }

    // ─── The stretched pill (grows to the left) ──────────────────────────────
    Item {
        id: bubble
        anchors.right: dot.left
        anchors.rightMargin: 12 * root.s
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, root.width - root.dotW - 12 * root.s - root.pad)
        height: root.height
        clip: true
        opacity: root.active ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        /** Remembered so the text stays put while the pill shrinks away. */
        property var shown: null
        Connections {
            target: root
            function onSubjectChanged() { if (root.subject) bubble.shown = root.subject; }
        }
        Component.onCompleted: shown = root.subject

        readonly property string title: shown ? (shown.where ? shown.name + " · " + shown.where.split(" ")[0] : Claude.title(shown)) : ""
        readonly property string line: !shown ? ""
            : shown.status === "waiting" ? (shown.action || "needs permission")
            : shown.status === "question" ? (shown.action || "has a question")
            : (shown.last || "done")

        implicitWidth: titleText.implicitWidth + 8 * root.s + Math.min(lineText.implicitWidth, 260 * root.s)

        Text {
            id: titleText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: bubble.title
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 11.5 * root.s
            font.weight: Font.DemiBold
        }

        Text {
            id: lineText
            anchors.left: titleText.right
            anchors.leftMargin: 8 * root.s
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: bubble.line
            color: bubble.shown && bubble.shown.status !== "done" ? Theme.accent : Theme.textSubtle
            font.family: Theme.font
            font.pixelSize: 11 * root.s
            font.weight: Font.Medium
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.active
            cursorShape: Qt.PointingHandCursor
            onClicked: if (bubble.shown) Claude.focus(bubble.shown.id)
        }
    }
}
