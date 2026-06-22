import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    PanelWindow {
        id: root
        
        // Notch active mode: "collapsed", "launcher", "clipboard", "web", "power"
        property string activeMode: "collapsed"
        
        // Set layer and keyboard focus properties dynamically for Wayland layer-shell
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (activeMode === "launcher" || activeMode === "clipboard" || activeMode === "web" || activeMode === "power") ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        
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
        // (matches the non-hovered notch height of 38px)
        exclusiveZone: 38
        
        // Keep the main window background transparent to show the floating notch
        color: "transparent"
    
    // The clock source
    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
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
                return contentLayout.width + 30;
            } else if (root.activeMode === "power") {
                return 500; // Wide horizontal box for power options
            } else { // launcher, clipboard, or web
                return 600;
            }
        }
        height: {
            if (root.activeMode === "collapsed") {
                return 38;
            } else if (root.activeMode === "launcher" || root.activeMode === "web") {
                return 550;
            } else if (root.activeMode === "clipboard") {
                return 350;
            } else if (root.activeMode === "power") {
                return 190;
            }
            return 38;
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
                height: 38
                
                Row {
                    id: contentLayout
                    anchors.centerIn: parent
                    spacing: 8
                    
                    // Clock icon
                    Text {
                        text: "󱑂"
                        color: "#89b4fa" // Soft blue accent
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    // Clock text
                    Text {
                        id: clockText
                        text: Qt.formatDateTime(systemClock.date, "ddd, MMM d  •  hh:mm:ss AP")
                        color: "#cdd6f4" // Soft white text
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
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
