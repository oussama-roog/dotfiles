pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Niri workspace data singleton. Listens to the Niri event-stream for live
 * workspace updates and exposes them as a sorted list with is_active flags.
 * Replaces the Hyprland workspace model for the pill's Workspaces widget.
 */
Singleton {
    id: root

    property var workspaces: []
    property int activeId: -1

    // Initial load of workspaces
    Process {
        id: initProc
        command: ["niri", "msg", "--json", "workspaces"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var wss = JSON.parse(this.text);
                    wss.sort(function(a, b) { return a.idx - b.idx; });
                    root.workspaces = wss;
                    for (var i = 0; i < wss.length; i++) {
                        if (wss[i].is_active) {
                            root.activeId = wss[i].id;
                            break;
                        }
                    }
                } catch(e) {}
            }
        }
    }

    // Persistent event stream for live updates
    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: (message) => {
                try {
                    var obj = JSON.parse(message);
                    if (obj.WorkspacesChanged) {
                        var wss = obj.WorkspacesChanged.workspaces;
                        wss.sort(function(a, b) { return a.idx - b.idx; });
                        root.workspaces = wss;
                        for (var i = 0; i < wss.length; i++) {
                            if (wss[i].is_active) {
                                root.activeId = wss[i].id;
                                break;
                            }
                        }
                    } else if (obj.WorkspaceActivated) {
                        var activeId = obj.WorkspaceActivated.id;
                        root.activeId = activeId;
                        var copy = [];
                        for (var j = 0; j < root.workspaces.length; j++) {
                            var ws = root.workspaces[j];
                            copy.push({
                                id: ws.id,
                                idx: ws.idx,
                                name: ws.name,
                                output: ws.output,
                                is_urgent: ws.is_urgent,
                                is_active: (ws.id === activeId),
                                is_focused: (ws.id === activeId),
                                active_window_id: ws.active_window_id
                            });
                        }
                        root.workspaces = copy;
                    }
                } catch(e) {}
            }
        }

        onRunningChanged: {
            if (!running) running = true;
        }
    }
}
