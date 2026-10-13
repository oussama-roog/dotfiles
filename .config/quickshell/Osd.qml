import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Io
import "services"
import "widgets"

/**
 * On-screen display shown inside the pill when something changes: volume,
 * screen brightness, battery starting to charge, or a media player starting or
 * changing track. `flashing` is true while one is showing; Pill morphs to
 * `desiredW` x `desiredH` for it.
 */
Item {
    id: root

    property real s: 1
    property bool suppressed: false
    property bool flashing: false
    property string kind: "volume"
    property bool armed: false
    property bool dirty: false
    property bool cooling: false

    /**
     * The player the current flash speaks for. Normally the active source, but an
     * announce can point it at another player that just started, so a video over
     * your music still gets its own flash without stealing the surface.
     */
    property var pendingSubject: null
    readonly property var subject: pendingSubject ? pendingSubject : Players.active
    readonly property bool subjectHas: subject !== null
    readonly property bool subjectPlaying: subjectHas && subject.isPlaying
    readonly property string subjectTitle: subjectHas && subject.trackTitle ? subject.trackTitle : ""
    readonly property string subjectArtist: subjectHas ? Players.artistsOf(subject.trackArtists, subject.trackArtist) : ""
    readonly property string subjectIcon: subjectHas ? Players.appIconFor(subject) : ""

    /** The rest pill's width: a track flash never gets narrower, so it only widens. */
    property real minW: 0

    property real brightness: 0
    property int lastBrightness: -1

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? Math.max(0, Math.min(1, sink.audio.volume)) : 0

    /**
     * Every flash keeps the rest pill's height and only ever widens: a track
     * grows sideways to fit its line, the meters (volume, brightness, battery)
     * take the rest width, or a little more on a narrow bar.
     */
    readonly property real desiredW: kind === "track"
        ? Math.max(minW, Math.min(trackLine.implicitWidth + 36 * s, 600 * s))
        : Math.max(minW, 280 * s)
    readonly property real desiredH: 38 * s

    /**
     * Leading-edge throttle. The first change flashes at once so a real track
     * switch feels instant, then the cooldown mutes the burst that hovering the
     * YouTube grid throws off. Anything that lands during the cooldown, or while
     * the OSD is suppressed (a surface open), stays `dirty` and
     * fires when the gate opens, so the stashed-player flash still replays.
     */
    function tryShow() {
        if (cooling)
            return;
        if (flash("track")) {
            dirty = false;
            cooling = true;
            cooldownTimer.restart();
        }
    }

    function flash(which) {
        if (!armed || suppressed)
            return false;
        kind = which;
        flashing = true;
        hideTimer.interval = which === "battery" ? 2000 : 1800;
        hideTimer.restart();
        return true;
    }

    onSuppressedChanged: {
        if (suppressed) {
            hideTimer.stop();
            flashing = false;
        } else if (dirty) {
            tryShow();
        }
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: cooldownTimer
        interval: 1500
        onTriggered: {
            root.cooling = false;
            if (root.dirty)
                root.tryShow();
        }
    }

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: root.flashing = false
    }

    PwObjectTracker {
        objects: [root.sink].filter(Boolean)
    }

    Connections {
        target: root.sink && root.sink.audio ? root.sink.audio : null
        function onVolumesChanged() { root.flash("volume"); }
        function onMutedChanged() { root.flash("volume"); }
    }

    Connections {
        target: Players
        function onAnnounce(player) {
            root.pendingSubject = player;
            root.dirty = true;
            root.tryShow();
        }
    }

    Connections {
        target: Battery
        enabled: Battery.present
        function onChargingChanged() {
            if (Battery.charging)
                root.flash("battery");
        }
    }

    Process {
        id: brightMonitor
        command: ["sh", "-c", "dev=$(ls /sys/class/backlight 2>/dev/null | head -n1); [ -n \"$dev\" ] || exit 0; max=$(cat /sys/class/backlight/$dev/max_brightness); last=\"\"; while true; do val=$(cat /sys/class/backlight/$dev/brightness); if [ \"$val\" != \"$last\" ]; then echo \"$(( val * 100 / max ))\"; last=\"$val\"; fi; sleep 0.4; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var pct = parseInt(line.trim(), 10);
                if (isNaN(pct))
                    return;
                var seen = root.lastBrightness >= 0;
                root.brightness = Math.max(0, Math.min(100, pct)) / 100.0;
                root.lastBrightness = pct;
                if (seen)
                    root.flash("brightness");
            }
        }
    }

    /** Icon, level bar and percentage; one per kind, cross-faded by `kind`. */
    component Meter: Item {
        id: meter
        property string forKind: ""
        property string icon: ""
        property real value: 0
        property bool muted: false

        anchors.fill: parent
        opacity: root.kind === forKind ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Icon {
            id: meterGlyph
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            size: 18 * root.s
            text: meter.icon
            color: meter.muted ? Theme.textDim : Theme.icon
        }

        Text {
            id: meterPct
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 32 * root.s
            horizontalAlignment: Text.AlignRight
            text: Math.round(meter.value * 100) + "%"
            color: meter.muted ? Theme.textDim : Theme.text
            font.family: Theme.font
            font.pixelSize: 11 * root.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
        }

        Rectangle {
            anchors.left: meterGlyph.right
            anchors.leftMargin: 12 * root.s
            anchors.right: meterPct.left
            anchors.rightMargin: 12 * root.s
            anchors.verticalCenter: parent.verticalCenter
            height: 4 * root.s
            radius: 2 * root.s
            color: Theme.hair

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * meter.value
                radius: parent.radius
                color: meter.muted ? Theme.accentDim : Theme.accent
                Behavior on width { NumberAnimation { duration: Motion.fast } }
                Behavior on color { ColorAnimation { duration: Motion.fast } }
            }
        }
    }

    Meter {
        forKind: "volume"
        icon: root.muted ? Icons.speakerOff : Icons.speaker
        value: root.volume
        muted: root.muted
    }

    Meter {
        forKind: "brightness"
        icon: Icons.sun
        value: root.brightness
    }

    /**
     * Track flash, one line at the notch's own height: a state glyph (equaliser
     * bars while playing, pause when paused), the title, the artist dimmed, and
     * the player's app icon. No cover; the agents centre shows that.
     */
    Item {
        id: trackRow
        anchors.fill: parent
        opacity: root.kind === "track" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Row {
            id: trackLine
            anchors.centerIn: parent
            spacing: 10 * root.s

            readonly property real titleW: Math.min(trackTitle.implicitWidth, 280 * root.s)
            readonly property real artistW: Math.min(trackArtist.implicitWidth, 180 * root.s)

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 14 * root.s
                height: 14 * root.s

                EqBars {
                    anchors.centerIn: parent
                    s: root.s
                    visible: root.subjectPlaying
                    running: trackRow.visible
                }

                Icon {
                    anchors.centerIn: parent
                    size: 14 * root.s
                    visible: !root.subjectPlaying
                    text: root.subjectHas ? Icons.pause : Icons.music
                    color: Theme.icon
                }
            }

            Text {
                id: trackTitle
                anchors.verticalCenter: parent.verticalCenter
                width: trackLine.titleW
                text: root.subjectHas ? root.subjectTitle : "Nothing playing"
                color: root.subjectPlaying ? Theme.text : Theme.textSubtle
                font.family: Theme.font
                font.pixelSize: 13 * root.s
                font.weight: Font.DemiBold
                maximumLineCount: 1
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            Text {
                id: trackArtist
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? trackLine.artistW : 0
                text: root.subjectArtist
                visible: text.length > 0
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: 11.5 * root.s
                maximumLineCount: 1
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? 15 * root.s : 0
                height: 15 * root.s
                sourceSize: Qt.size(Math.ceil(15 * root.s * 2), Math.ceil(15 * root.s * 2))
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                source: root.subjectIcon
                visible: status === Image.Ready
                opacity: 0.85
            }
        }
    }

    Item {
        anchors.fill: parent
        opacity: root.kind === "battery" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Icon {
            id: battGlyph
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            size: 18 * root.s
            text: Icons.lightning
            color: Theme.accent
        }

        Text {
            id: battPct
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 40 * root.s
            horizontalAlignment: Text.AlignRight
            text: Battery.pct + "%"
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 11 * root.s
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
        }

        Rectangle {
            anchors.left: battGlyph.right
            anchors.leftMargin: 12 * root.s
            anchors.right: battPct.left
            anchors.rightMargin: 12 * root.s
            anchors.verticalCenter: parent.verticalCenter
            height: 4 * root.s
            radius: 2 * root.s
            color: Theme.hair
            clip: true

            Rectangle {
                id: battFill
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Battery.frac
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Theme.accentDeep }
                    GradientStop { position: 1.0; color: Theme.accent }
                }
                Behavior on width { NumberAnimation { duration: Motion.fast } }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 34 * root.s
                    color: "transparent"
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.alpha(Theme.textBright, 0.33) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    NumberAnimation on x {
                        from: -34 * root.s
                        to: battFill.width
                        duration: 1200
                        loops: Animation.Infinite
                        running: root.kind === "battery" && Battery.charging
                    }
                }
            }
        }
    }
}
