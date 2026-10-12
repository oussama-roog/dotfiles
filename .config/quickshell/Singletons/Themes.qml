pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Theme-switcher bridge: keeps an in-memory snapshot of every base16 scheme so
 * the themes surface opens instantly. The scheme store path is resolved once
 * through nix, then a single awk pass reads each yaml's display name and the
 * palette slots the swatch strip shows. `current` mirrors the switcher's cache
 * file and follows it live, so picks made from a terminal show up too. Applying
 * routes through theme-switcher.sh so every app gets the same palette.
 *
 * Entries are plain objects: { id, name, swatches } where id is the yaml
 * basename theme-switcher.sh expects and swatches is [bg, fg, accents...].
 */
Singleton {
    id: root

    property var entries: []
    readonly property int count: entries.length
    property string current: ""
    property bool applying: false

    readonly property string script: Quickshell.env("HOME") + "/dotfiles/scripts/theme-switcher.sh"

    function refresh() {
        if (entries.length === 0 && !listProc.running)
            listProc.running = true;
    }

    function apply(id) {
        if (applying || !/^[A-Za-z0-9._-]+$/.test(id))
            return;
        applyProc.command = [script, "apply", id];
        applying = true;
        applyProc.running = true;
    }

    function random() {
        if (applying)
            return;
        applyProc.command = [script, "random"];
        applying = true;
        applyProc.running = true;
    }

    Process {
        id: listProc
        command: ["sh", "-c",
            "d=$(nix eval --raw nixpkgs#base16-schemes.outPath 2>/dev/null)/share/themes; "
            + "awk 'FNR==1 { if (id) print id \"\\t\" n \"\\t\" c; id=FILENAME; sub(/.*\\//, \"\", id); sub(/\\.yaml$/, \"\", id); n=id; c=\"\" } "
            + "/^name:/ { n=$0; sub(/^name: *\"?/, \"\", n); sub(/\"? *$/, \"\", n) } "
            + "/^  base0[0589ABDE]:/ { v=$2; gsub(/\"/, \"\", v); sub(/^#?/, \"#\", v); c = c (c ? \",\" : \"\") v } "
            + "END { if (id) print id \"\\t\" n \"\\t\" c }' \"$d\"/*.yaml"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = [];
                var lines = text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var f = lines[i].split("\t");
                    if (f.length < 3 || !f[0].length)
                        continue;
                    out.push({ id: f[0], name: f[1], swatches: f[2].split(",") });
                }
                out.sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
                root.entries = out;
            }
        }
    }

    Process {
        id: applyProc
        onExited: root.applying = false
    }

    FileView {
        id: currentFile
        path: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/theme-switcher/current-theme"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.current = text().trim()
    }
}
