import QtQuick
import Quickshell.Widgets
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
    property int holdExtends: 0

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

    /** Subject art, live so a cover that lands a beat after the title still resolves; the key forces a reload when a browser reuses one file path. */
    readonly property string liveArt: {
        if (!subjectHas)
            return "";
        var u = Players.artUrlFor(subject);
        if (!u)
            return "";
        return u.indexOf("file:") === 0 ? u + "#" + Players.keyFor(subject) : u;
    }

    property real brightness: 0
    property int lastBrightness: -1

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? Math.max(0, Math.min(1, sink.audio.volume)) : 0

    readonly property real desiredW: (kind === "track" ? 344 : 248) * s
    readonly property real desiredH: kind === "track" ? 64 * s : 44 * s

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
        if (which === "track")
            holdExtends = 0;
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

    /**
     * Hold a track flash open until its cover decodes, so a cold remote thumbnail
     * that arrives after the base window still gets seen. Capped so a dead art url
     * never pins the OSD.
     */
    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: {
            if (root.kind === "track" && cover.status !== Image.Ready && root.liveArt.length > 0 && root.holdExtends < 5) {
                root.holdExtends++;
                hideTimer.interval = 350;
                hideTimer.restart();
            } else {
                root.flashing = false;
            }
        }
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

        GlyphIcon {
            id: meterGlyph
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 17 * root.s
            height: 17 * root.s
            name: meter.icon
            color: meter.muted ? Theme.textDim : Theme.icon
            stroke: 1.7
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
        icon: root.muted ? "speaker-off" : "speaker"
        value: root.volume
        muted: root.muted
    }

    Meter {
        forKind: "brightness"
        icon: "sun"
        value: root.brightness
    }

    Item {
        id: trackRow
        anchors.fill: parent
        opacity: root.kind === "track" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 150 } }

        ClippingRectangle {
            id: coverBox
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 44 * root.s
            height: 44 * root.s
            radius: 9 * root.s
            color: Theme.tileBg

            Image {
                id: cover
                anchors.fill: parent
                source: root.liveArt
                sourceSize: Qt.size(Math.ceil(width * 2), Math.ceil(height * 2))
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: String(source).indexOf("file:") !== 0
                opacity: status === Image.Ready ? 1 : 0
                /** Art that arrives late still earns a moment on screen, so a cover
                 *  decoded near the end of the flash is actually seen. */
                onStatusChanged: if (status === Image.Ready && root.flashing && root.kind === "track") {
                    hideTimer.interval = 1300;
                    hideTimer.restart();
                }
            }
            GlyphIcon {
                anchors.centerIn: parent
                width: parent.width * 0.42
                height: width
                name: "music"
                color: Theme.textSubtle
                visible: cover.status !== Image.Ready
            }

            /** The source's own app icon, sat as a small badge on the art corner. */
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 3 * root.s
                width: 18 * root.s
                height: 18 * root.s
                radius: width / 2
                color: Qt.alpha(Theme.cardBot, 0.8)
                visible: srcIcon.status === Image.Ready

                Image {
                    id: srcIcon
                    anchors.centerIn: parent
                    width: 12 * root.s
                    height: 12 * root.s
                    sourceSize: Qt.size(Math.ceil(width * 2), Math.ceil(height * 2))
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    source: root.subjectIcon
                }
            }
        }

        GlyphIcon {
            id: trackCtrl
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 18 * root.s
            height: 18 * root.s
            name: root.subjectPlaying ? "play" : "pause"
            color: root.subjectPlaying ? Theme.accent : Theme.icon
        }

        Column {
            anchors.left: coverBox.right
            anchors.leftMargin: 12 * root.s
            anchors.right: trackCtrl.left
            anchors.rightMargin: 12 * root.s
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3 * root.s

            Text {
                width: parent.width
                text: root.subjectHas ? root.subjectTitle : "Nothing playing"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 14 * root.s
                font.weight: Font.DemiBold
                maximumLineCount: 1
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.subjectArtist
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: 11 * root.s
                maximumLineCount: 1
                elide: Text.ElideRight
                visible: text.length > 0
            }
        }
    }

    Item {
        id: batteryRow
        anchors.fill: parent
        opacity: root.kind === "battery" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 150 } }

        GlyphIcon {
            id: battGlyph
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 17 * root.s
            height: 17 * root.s
            name: "bolt"
            color: Theme.accent
            stroke: 1.7
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
