pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * cliphist bridge: keeps a warm in-memory snapshot of the clipboard history so
 * the clipboard surface opens instantly without shelling out on demand. A
 * wl-paste watcher fires on every clipboard change; after a short debounce the
 * missing image previews are decoded to small pngs (stale ones pruned),
 * then `cliphist list` is re-read into `entries`. Thumbnails are written before
 * the list lands so image delegates never bind to a not-yet-existing file. A
 * change arriving while the pipeline runs sets `pending` and replays once the
 * list lands, so no clipboard event is ever silently dropped; the watcher
 * respawns through a cooldown timer if wl-paste dies.
 *
 * Entries are plain objects: { id, preview, isImage, kind, label, sizeLabel,
 * thumb } where kind is "image", "link", "color" or "text", label/sizeLabel
 * split cliphist's binary descriptor ("png 1920×1080" / "245 KiB") and thumb is
 * the cached preview png (empty for text).
 *
 * `show(entry)` loads the selected entry in full for the preview pane: the whole
 * text (capped at 64 KiB) into `shownText`, or the image decoded once into the
 * cache into `shownImage`. Selection can move faster than cliphist decodes; the
 * newest request wins and replays when the running one lands.
 */
Singleton {
    id: root

    property var entries: []
    readonly property int count: entries.length
    property bool pending: false

    readonly property string thumbDir: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/quickshell/cliphist-thumbs/"
    readonly property string fullDir: thumbDir + "full/"

    /** Kind of a text entry, from its one-line preview. */
    function kindOf(text) {
        var t = text.trim();
        if (/^#([0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$/i.test(t))
            return "color";
        if (/^(https?|ftp|file):\/\/\S+$/i.test(t))
            return "link";
        return "text";
    }

    // ─── Full preview of the selected entry ──────────────────────────────────
    property string shownId: ""
    property string shownText: ""
    property bool shownTruncated: false
    property string shownImage: ""
    property bool shownLoading: false
    property var wanted: null
    readonly property int shownCap: 65536

    function show(entry) {
        wanted = entry || null;
        if (!entry) {
            shownId = "";
            shownText = "";
            shownImage = "";
            return;
        }
        if (String(entry.id) === shownId && !shownLoading)
            return;
        showDebounce.restart();
    }

    function loadWanted() {
        var e = wanted;
        if (!e || showProc.running || !/^\d+$/.test(String(e.id)))
            return;
        shownLoading = true;
        showProc.target = e;
        showProc.command = e.isImage
            ? ["sh", "-c", "mkdir -p \"$2\"; f=\"$2$1\"; [ -s \"$f\" ] || cliphist decode \"$1\" > \"$f\"; printf '%s' \"$f\"", "_", String(e.id), fullDir]
            : ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | head -c \"$2\"", "_", String(e.id), String(shownCap + 1)];
        showProc.running = true;
    }

    Timer {
        id: showDebounce
        interval: 40
        onTriggered: root.loadWanted()
    }

    Process {
        id: showProc
        property var target: null
        stdout: StdioCollector {
            onStreamFinished: {
                var e = showProc.target;
                if (e.isImage) {
                    root.shownText = "";
                    root.shownTruncated = false;
                    root.shownImage = this.text.length ? "file://" + this.text : "";
                } else {
                    var t = this.text;
                    root.shownTruncated = t.length > root.shownCap;
                    root.shownText = root.shownTruncated ? t.substring(0, root.shownCap) : t;
                    root.shownImage = "";
                }
                root.shownId = String(e.id);
            }
        }
        onExited: {
            root.shownLoading = false;
            if (root.wanted && String(root.wanted.id) !== root.shownId)
                root.loadWanted();
        }
    }

    function refresh() {
        if (thumbProc.running || listProc.running || delProc.running || delQueue.length) {
            pending = true;
            return;
        }
        thumbProc.running = true;
    }

    function copy(entry) {
        if (!/^\d+$/.test(String(entry.id)))
            return;
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "_", String(entry.id)]);
    }

    function wipe() {
        entries = [];
        wipeProc.running = true;
    }

    /**
     * Deletes are queued through a tracked process and any refresh is held
     * until the queue drains: a fire-and-forget delete racing an in-flight
     * `cliphist list` used to resurrect the removed entry from the stale
     * snapshot. The local prune stays optimistic so the row vanishes
     * immediately.
     */
    property var delQueue: []

    function remove(entry) {
        var id = String(entry.id);
        if (!/^\d+$/.test(id))
            return;
        var kept = [];
        for (var i = 0; i < entries.length; i++)
            if (entries[i].id !== id)
                kept.push(entries[i]);
        entries = kept;
        delQueue.push(id);
        pumpDeletes();
    }

    function pumpDeletes() {
        if (delProc.running || !delQueue.length)
            return;
        var id = delQueue.shift();
        delProc.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "_", id];
        delProc.running = true;
    }

    Process {
        id: delProc
        onExited: {
            if (root.delQueue.length)
                root.pumpDeletes();
            else
                root.refresh();
        }
    }

    Process {
        id: watchProc
        command: ["wl-paste", "--watch", "echo", "x"]
        running: true
        stdout: SplitParser {
            onRead: debounce.restart()
        }
        onExited: respawn.restart()
    }

    Timer {
        id: respawn
        interval: 2000
        onTriggered: watchProc.running = true
    }

    Timer {
        id: debounce
        interval: 300
        onTriggered: root.refresh()
    }

    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]
        onExited: root.refresh()
    }

    Process {
        id: thumbProc
        command: ["sh", "-c",
            "mkdir -p \"$1\"; ids=$(cliphist list | awk -F'\\t' '/^[0-9]+\\t\\[\\[ binary data .*(png|jpg|jpeg|gif|bmp|webp)/ { print $1 }'); "
            + "for id in $ids; do t=\"$1$id.png\"; [ -f \"$t\" ] || cliphist decode \"$id\" | ffmpeg -loglevel quiet -i - -vf scale=256:-1 -frames:v 1 -y \"$t\"; done; "
            + "for f in \"$1\"*.png; do [ -e \"$f\" ] || continue; n=${f##*/}; echo \"$ids\" | grep -qx \"${n%.png}\" || rm -f \"$f\"; done; "
            + "for f in \"$1\"full/*; do [ -e \"$f\" ] || continue; echo \"$ids\" | grep -qx \"${f##*/}\" || rm -f \"$f\"; done",
            "_", root.thumbDir]
        onExited: listProc.running = true
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split("\n");
                var out = [];
                var metaRe = /^\[\[ binary data (.*) \]\]$/;
                var imgRe = /\b(png|jpg|jpeg|gif|bmp|webp)\b/;
                var splitRe = /^(\S+ \S+) (\w+) (\d+)x(\d+)$/;
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i];
                    var tab = line.indexOf("\t");
                    if (tab < 1)
                        continue;
                    var id = line.substring(0, tab);
                    if (!/^\d+$/.test(id))
                        continue;
                    var preview = line.substring(tab + 1);
                    var m = metaRe.exec(preview);
                    var isImage = m !== null && imgRe.test(m[1]);
                    var label = "";
                    var sizeLabel = "";
                    if (isImage) {
                        var p = splitRe.exec(m[1]);
                        label = p ? p[2] + " " + p[3] + "×" + p[4] : m[1];
                        sizeLabel = p ? p[1] : "";
                    }
                    out.push({
                        id: id,
                        preview: preview,
                        isImage: isImage,
                        kind: isImage ? "image" : root.kindOf(preview),
                        label: label,
                        sizeLabel: sizeLabel,
                        thumb: isImage ? root.thumbDir + id + ".png" : ""
                    });
                }
                root.entries = out;
                if (root.pending) {
                    root.pending = false;
                    Qt.callLater(root.refresh);
                }
            }
        }
    }

    Component.onCompleted: refresh()
}
