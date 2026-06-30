import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
    PanelWindow {
        id: root
        
        // Notch active mode: "collapsed", "launcher", "clipboard", "web", "power", "notifications"
        property string activeMode: "collapsed"
        
        readonly property alias notificationServer: notificationServer
        
        NotificationServer {
            id: notificationServer
            onNotification: (notification) => {
                notification.tracked = true
            }
        }
        
        // Set layer and keyboard focus properties dynamically for Wayland layer-shell
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (activeMode === "launcher" || activeMode === "clipboard" || activeMode === "web" || activeMode === "power" || activeMode === "notifications") ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        
        // Handle input focus when opening launcher, clipboard, web, or power selector
        onActiveModeChanged: {
            if (activeMode === "launcher") {
                launcherView.forceFocus();
            } else if (activeMode === "clipboard") {
                clipboardView.forceFocus();
            } else if (activeMode === "web") {
                webView.forceFocus();
            } else if (activeMode === "power") {
                powerView.forceFocus();
            } else if (activeMode === "notifications") {
                notificationsView.forceFocus();
            }
        }
        
        // IPC Interface for the application launcher
        IpcHandler {
            target: "launcher"
            
            function toggle(): void {
                if (root.activeMode === "launcher") {
                    root.activeMode = "collapsed";
                } else {
                    root.activeMode = "launcher";
                }
            }
        }
        
        // IPC Interface for the clipboard history
        IpcHandler {
            target: "clipboard"
            
            function toggle(): void {
                if (root.activeMode === "clipboard") {
                    root.activeMode = "collapsed";
                } else {
                    root.activeMode = "clipboard";
                }
            }
        }
        
        // IPC Interface for the web application launcher
        IpcHandler {
            target: "web"
            
            function toggle(): void {
                if (root.activeMode === "web") {
                    root.activeMode = "collapsed";
                } else {
                    root.activeMode = "web";
                }
            }
        }
        
        // IPC Interface for the power menu
        IpcHandler {
            target: "power"
            
            function toggle(): void {
                if (root.activeMode === "power") {
                    root.activeMode = "collapsed";
                } else {
                    root.activeMode = "power";
                }
            }
        }
        
        // IPC Interface for notifications
        IpcHandler {
            target: "notifications"
            
            function toggle(): void {
                if (root.activeMode === "notifications") {
                    root.activeMode = "collapsed";
                } else {
                    root.activeMode = "notifications";
                }
            }
        }
        
        // Anchors to attach to the top of the screen
        anchors {
            top: true
            left: true
            right: true
        }
        
        // Height of the bar container (large enough to accommodate the expanded state)
        implicitHeight: 600
        
        // Define the input mask so only the notch itself captures mouse clicks/events.
        // The rest of the transparent window is completely click-through.
        mask: Region { item: notchContainer }
        
        // Set exclusive zone so windows don't cover the bar area
        // (matches the non-hovered notch height of 40px)
        exclusiveZone: 40
        
        // Keep the main window background transparent to show the floating notch
        color: "transparent"
    
    // System stats and workspaces properties
    property int cpuPercent: 0
    property int ramPercent: 0
    property string wifiState: "down"
    property var workspacesList: []
    property int batPercent: 0
    property string batStatus: "Unknown"

    function getBatteryIcon(percentage, status) {
        if (status === "Charging") {
            return "";
        }
        if (percentage <= 15) return "";
        if (percentage <= 35) return "";
        if (percentage <= 60) return "";
        if (percentage <= 85) return "";
        return "";
    }

    // Process to listen to Niri workspaces events
    Process {
        id: niriEventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: (message) => {
                try {
                    let obj = JSON.parse(message);
                    if (obj.WorkspacesChanged) {
                        let workspaces = obj.WorkspacesChanged.workspaces;
                        workspaces.sort((a, b) => a.idx - b.idx);
                        root.workspacesList = workspaces;
                    } else if (obj.WorkspaceActivated) {
                        let activeId = obj.WorkspaceActivated.id;
                        let listCopy = [];
                        for (let i = 0; i < root.workspacesList.length; i++) {
                            let ws = root.workspacesList[i];
                            listCopy.push({
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
                        root.workspacesList = listCopy;
                    }
                } catch (e) {
                    // Ignore parsing errors for other event types
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                running = true;
            }
        }
    }

    // Process to periodically fetch CPU, RAM, WiFi, and Battery state
    Process {
        id: sysStatsProc
        command: ["sh", "-c", "cpu=$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'); ram=$(free | grep Mem | awk '{print ($3/$2)*100}'); wifi=$(cat /sys/class/net/wlp58s0/operstate 2>/dev/null || echo 'down'); bat_percent=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0); bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo 'Unknown'); echo \"{\\\"cpu\\\": ${cpu:-0}, \\\"ram\\\": ${ram:-0}, \\\"wifi\\\": \\\"$wifi\\\", \\\"bat_percent\\\": ${bat_percent:-0}, \\\"bat_status\\\": \\\"$bat_status\\\"}\""]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let stats = JSON.parse(this.text);
                    root.cpuPercent = Math.round(stats.cpu);
                    root.ramPercent = Math.round(stats.ram);
                    root.wifiState = stats.wifi;
                    root.batPercent = Math.round(stats.bat_percent);
                    root.batStatus = stats.bat_status;
                } catch(e) {
                    // Ignore parsing errors
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: sysStatsProc.running = true
    }

    // The clock source
    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }
    
    // Container that holds the floating island panel
    Item {
        id: notchContainer
        anchors.top: parent.top
        anchors.topMargin: 8 // Floating gap below the top screen edge
        anchors.horizontalCenter: parent.horizontalCenter
        
        // Animate width and height depending on activeMode directly on the container
        width: {
            if (root.activeMode === "collapsed") {
                return contentLayout.width + 40;
            } else if (root.activeMode === "power") {
                return 500; // Wide horizontal box for power options
            } else { // launcher, clipboard, or web
                return 600;
            }
        }
        height: {
            if (root.activeMode === "collapsed") {
                return 40;
            } else if (root.activeMode === "launcher" || root.activeMode === "web" || root.activeMode === "notifications") {
                return 550;
            } else if (root.activeMode === "clipboard") {
                return 350;
            } else if (root.activeMode === "power") {
                return 190;
            }
            return 40;
        }
        
        // Smooth transitions for dimensions on the container
        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        
        Behavior on height {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        
        // The actual notch panel
        Rectangle {
            id: pill
            anchors.fill: parent
            radius: 18 // Rounded corners on all 4 sides for floating pill
            
            // Catppuccin Mocha-inspired premium dark palette
            color: root.activeMode !== "collapsed" ? "#1e1e2e" : "#11111b"
            border.color: root.activeMode !== "collapsed" ? "#89b4fa" : "#313244"
            border.width: 1
            
            // Smooth transitions for colors
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }
            
            // Fixed-height header at the top of the floating notch for the clock
            Item {
                id: headerArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                
                Row {
                    id: contentLayout
                    anchors.centerIn: parent
                    spacing: 48
                    
                    // Left section: Nix logo + workspaces
                    Row {
                        spacing: 12
                        anchors.verticalCenter: parent.verticalCenter
                        
                        // Nix logo
                        Text {
                            text: "󱄅"
                            color: "#89b4fa" // Soft blue accent matching your theme
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        // Workspaces
                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Repeater {
                                model: root.workspacesList
                                
                                delegate: Rectangle {
                                    width: modelData.is_active ? 24 : 8
                                    height: 8
                                    radius: 4
                                    color: modelData.is_active ? "#89b4fa" : "#313244"
                                    
                                    Behavior on width {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Center section: Clock (just hours and minutes, no seconds or date)
                    Row {
                        spacing: 6
                        anchors.verticalCenter: parent.verticalCenter
                        
                        // Clock icon
                        Text {
                            text: "󱑂"
                            color: "#89b4fa"
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        // Clock text
                        Text {
                            id: clockText
                            text: Qt.formatDateTime(systemClock.date, "hh:mm AP")
                            color: "#cdd6f4"
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    // Right section: CPU + RAM + Wifi + Battery
                    Row {
                        spacing: 12
                        anchors.verticalCenter: parent.verticalCenter
                        
                        // Notifications Bell Button
                        Item {
                            width: bellRow.width
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Row {
                                id: bellRow
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Text {
                                    text: root.notificationServer && root.notificationServer.trackedNotifications.values.length > 0 ? "󱅫" : "󰂚"
                                    color: root.notificationServer && root.notificationServer.trackedNotifications.values.length > 0 ? "#f9e2af" : "#a6adc8"
                                    font.family: "JetBrainsMono Nerd Font Propo"
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: root.notificationServer && root.notificationServer.trackedNotifications.values.length > 0 ? root.notificationServer.trackedNotifications.values.length : ""
                                    color: "#f9e2af"
                                    font.family: "JetBrainsMono Nerd Font Propo"
                                    font.pixelSize: 11
                                    font.bold: true
                                    visible: text !== ""
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (root.activeMode === "notifications") {
                                        root.activeMode = "collapsed";
                                    } else {
                                        root.activeMode = "notifications";
                                    }
                                }
                            }
                        }
                        
                        // CPU
                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: ""
                                color: "#f38ba8" // Catppuccin red
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: root.cpuPercent + "%"
                                color: "#cdd6f4"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // RAM
                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: ""
                                color: "#a6e3a1" // Catppuccin green
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: root.ramPercent + "%"
                                color: "#cdd6f4"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // Wifi
                        Text {
                            text: root.wifiState === "up" ? "" : "󰖪"
                            color: root.wifiState === "up" ? "#89dceb" : "#f38ba8"
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        // Battery
                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: root.getBatteryIcon(root.batPercent, root.batStatus)
                                color: root.batStatus === "Charging" ? "#a6e3a1" : (root.batPercent <= 20 ? "#f38ba8" : "#f9e2af")
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: root.batPercent + "%"
                                color: "#cdd6f4"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
            
            // The expanded content area below the header
            Item {
                id: expandedContent
                anchors.top: headerArea.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                
                // Fade in the content when expanded
                visible: root.activeMode !== "collapsed" || opacity > 0
                opacity: root.activeMode !== "collapsed" ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
                
                // APPLICATION LAUNCHER VIEW
                LauncherView {
                    id: launcherView
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.bottomMargin: 15
                    
                    visible: root.activeMode === "launcher" || opacity > 0
                    opacity: root.activeMode === "launcher" ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    onClosed: root.activeMode = "collapsed"
                    
                    onVisibleChanged: {
                        if (!visible) {
                            reset();
                        }
                    }
                }
                
                // CLIPBOARD HISTORY VIEW
                ClipboardView {
                    id: clipboardView
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.bottomMargin: 15
                    
                    visible: root.activeMode === "clipboard" || opacity > 0
                    opacity: root.activeMode === "clipboard" ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    onClosed: root.activeMode = "collapsed"
                    
                    onVisibleChanged: {
                        if (!visible) {
                            reset();
                        }
                    }
                }
                
                // WEB APPLICATION LAUNCHER VIEW
                WebView {
                    id: webView
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.bottomMargin: 15
                    
                    visible: root.activeMode === "web" || opacity > 0
                    opacity: root.activeMode === "web" ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    onClosed: root.activeMode = "collapsed"
                    
                    onVisibleChanged: {
                        if (!visible) {
                            reset();
                        }
                    }
                }
                
                // POWER MENU VIEW
                PowerView {
                    id: powerView
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.bottomMargin: 15
                    
                    visible: root.activeMode === "power" || opacity > 0
                    opacity: root.activeMode === "power" ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    onClosed: root.activeMode = "collapsed"
                    
                    onVisibleChanged: {
                        if (!visible) {
                            reset();
                        }
                    }
                }
                
                // NOTIFICATIONS VIEW
                NotificationsView {
                    id: notificationsView
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.bottomMargin: 15
                    
                    notificationServer: root.notificationServer
                    
                    visible: root.activeMode === "notifications" || opacity > 0
                    opacity: root.activeMode === "notifications" ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    onClosed: root.activeMode = "collapsed"
                    
                    onVisibleChanged: {
                        if (!visible) {
                            reset();
                        }
                    }
                }
            }
            
            // Click to toggle area (only covers the clock/header)
            MouseArea {
                id: clickArea
                anchors.fill: headerArea
                onClicked: {
                    if (root.activeMode !== "collapsed") {
                        root.activeMode = "collapsed";
                    }
                }
            }
        }
    }
}
}
