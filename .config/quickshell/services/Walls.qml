pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Wallpaper list for the wallpaper strip. A refresh generates any missing 512px
 * thumbnails, lists ~/dotfiles/wallpapers newest first, then re-reads
 * ~/.cache/current_wallpaper so `current` names the wallpaper on screen. A
 * refresh arriving mid-pipeline sets `pending` and replays once it finishes.
 *
 * Entries are plain objects: { path, thumb } where path is the absolute source
 * file and thumb the absolute path of the cached preview png.
 */
Singleton {
    id: root

    property var entries: []
    readonly property int count: entries.length
    property string current: ""
    property bool pending: false

    readonly property string wpDir: Quickshell.env("HOME") + "/dotfiles/wallpapers"
    readonly property string thumbDir: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/quickshell/wallpaper-thumbs/"
    readonly property string stateFile: Quickshell.env("HOME") + "/.cache/current_wallpaper"

    function refresh() {
        if (thumbProc.running || listProc.running || stateProc.running) {
            pending = true;
            return;
        }
        thumbProc.running = true;
    }

    /**
     * awww blocks through the whole transition, so a pick landing meanwhile is
     * queued and replayed once it exits; rapid picks converge on the last one.
     */
    property string queuedApply: ""

    function apply(path) {
        if (applyProc.running) {
            queuedApply = path;
            return;
        }
        run(path);
    }

    /** Remember the pick in the state file and fade to it with awww. */
    function run(path) {
        applyProc.command = ["bash", "-c",
            "echo \"$1\" > \"$2\"; awww img \"$1\" --transition-type fade --transition-fps 60",
            "_", path, root.stateFile];
        applyProc.running = true;
    }

    function trash(path) {
        trashProc.command = ["gio", "trash", path];
        trashProc.running = true;
        var kept = [];
        for (var i = 0; i < entries.length; i++)
            if (entries[i].path !== path)
                kept.push(entries[i]);
        entries = kept;
    }

    Process {
        id: trashProc
        onExited: function(exitCode) {
            if (exitCode !== 0)
                root.refresh();
        }
    }

    Process {
        id: thumbProc
        command: ["sh", "-c",
            "mkdir -p \"$2\"; find \"$1\" -type f \\( -iname '*.jpg' -o -iname '*.png' \\) | while read f; do "
            + "t=\"$2$(basename \"$f\").png\"; [ -f \"$t\" ] || ffmpeg -i \"$f\" -vf scale=512:-1 -frames:v 1 \"$t\" -y 2>/dev/null; done",
            "_", root.wpDir, root.thumbDir]
        onExited: listProc.running = true
    }

    Process {
        id: listProc
        command: ["sh", "-c", "find \"$1\" -type f \\( -iname '*.jpg' -o -iname '*.png' \\) -printf '%T@\\t%p\\n' | sort -rn", "_", root.wpDir]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split("\n");
                var out = [];
                for (var i = 0; i < lines.length; i++) {
                    var tab = lines[i].indexOf("\t");
                    if (tab < 1)
                        continue;
                    var path = lines[i].substring(tab + 1);
                    var name = path.substring(path.lastIndexOf("/") + 1);
                    out.push({
                        path: path,
                        thumb: root.thumbDir + name + ".png"
                    });
                }
                root.entries = out;
                stateProc.running = true;
            }
        }
    }

    Process {
        id: stateProc
        command: ["sh", "-c", "cat \"$1\" 2>/dev/null || true", "_", root.stateFile]
        stdout: StdioCollector {
            onStreamFinished: {
                root.current = this.text.trim();
                if (root.pending) {
                    root.pending = false;
                    Qt.callLater(root.refresh);
                }
            }
        }
    }

    Process {
        id: applyProc
        onExited: {
            if (root.queuedApply.length) {
                var next = root.queuedApply;
                root.queuedApply = "";
                root.run(next);
                return;
            }
            stateProc.running = true;
        }
    }

    Component.onCompleted: refresh()
}
