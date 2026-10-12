pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Niri workspaces, sorted by index, kept live from `niri msg event-stream`
 * (which also sends the full list when it connects). Each entry is niri's
 * workspace object; `is_active` marks the one shown on its output.
 */
Singleton {
    id: root

    property var workspaces: []

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        onRunningChanged: if (!running) running = true

        stdout: SplitParser {
            onRead: (message) => {
                try {
                    var ev = JSON.parse(message);
                    if (ev.WorkspacesChanged) {
                        root.workspaces = ev.WorkspacesChanged.workspaces.sort((a, b) => a.idx - b.idx);
                    } else if (ev.WorkspaceActivated) {
                        var id = ev.WorkspaceActivated.id;
                        var out = root.workspaces.find(w => w.id === id) ? root.workspaces : [];
                        var output = (out.find(w => w.id === id) || {}).output;
                        root.workspaces = out.map(w => Object.assign({}, w, {
                            is_active: w.output === output ? w.id === id : w.is_active
                        }));
                    }
                } catch (e) {}
            }
        }
    }
}
