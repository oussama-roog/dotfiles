import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

FocusScope {
    id: viewRoot
    
    property var notificationServer: null
    signal closed()
    
    function forceFocus() {
        notificationsList.forceActiveFocus();
    }
    
    function reset() {
        // Nothing special to reset for notifications
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            
            Text {
                text: "Notifications"
                color: "#89b4fa" // Accent blue
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 16
                font.bold: true
            }
            
            Item {
                Layout.fillWidth: true
            } // Pushes clear button to the right
            
            // Clear All Button (Only visible if there are notifications)
            Rectangle {
                id: clearBtn
                width: 90
                height: 28
                color: clearMouse.containsMouse ? "#313244" : "#181825"
                border.color: clearMouse.containsMouse ? "#f38ba8" : "#313244"
                border.width: 1
                radius: 6
                visible: viewRoot.notificationServer && viewRoot.notificationServer.trackedNotifications.values.length > 0
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    Text {
                        text: "󰅖"
                        color: clearMouse.containsMouse ? "#f38ba8" : "#a6adc8"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 12
                    }
                    Text {
                        text: "Clear All"
                        color: clearMouse.containsMouse ? "#f38ba8" : "#a6adc8"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
                
                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (viewRoot.notificationServer) {
                            let list = viewRoot.notificationServer.trackedNotifications.values;
                            for (let i = list.length - 1; i >= 0; i--) {
                                list[i].tracked = false;
                            }
                        }
                    }
                }
            }
        }
        
        // Notification List / Empty State container
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // EMPTY STATE
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12
                visible: !viewRoot.notificationServer || viewRoot.notificationServer.trackedNotifications.values.length === 0
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰂛"
                    color: "#45475a"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 48
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No notifications"
                    color: "#585b70"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
            
            // LIST VIEW
            ListView {
                id: notificationsList
                anchors.fill: parent
                clip: true
                spacing: 8
                focus: true
                
                model: viewRoot.notificationServer ? viewRoot.notificationServer.trackedNotifications.values : null
                
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        viewRoot.closed();
                        event.accepted = true;
                    }
                }
                
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    
                    width: notificationsList.width
                    // Height is dynamic to fit the title and body text wrapping
                    implicitHeight: cardLayout.implicitHeight + 20
                    color: "#181825"
                    border.color: "#313244"
                    border.width: 1
                    radius: 8
                    
                    RowLayout {
                        id: cardLayout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12
                        
                        // Left side: Notification/App Icon
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: "#1e1e2e"
                            Layout.alignment: Qt.AlignTop
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    // Map some app names to icons, fallback to bell
                                    let app = (modelData.appName || "").toLowerCase();
                                    if (app.includes("discord")) return "󰙯";
                                    if (app.includes("slack")) return "󰒱";
                                    if (app.includes("spotify")) return "󰓇";
                                    if (app.includes("firefox") || app.includes("chrome") || app.includes("brave")) return "󰈹";
                                    if (app.includes("terminal") || app.includes("kitty")) return "󰞷";
                                    return "󰂚";
                                }
                                color: "#89b4fa"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 16
                            }
                        }
                        
                        // Middle: App info, Title, Body, Actions
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Layout.alignment: Qt.AlignTop
                            
                            // App Name
                            Text {
                                text: modelData.appName || "Notification"
                                color: "#a6adc8"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 10
                                font.bold: true
                            }
                            
                            // Title / Summary
                            Text {
                                Layout.fillWidth: true
                                text: modelData.summary || ""
                                color: "#cdd6f4"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 13
                                font.bold: true
                                wrapMode: Text.Wrap
                            }
                            
                            // Body Text
                            Text {
                                Layout.fillWidth: true
                                text: modelData.body || ""
                                color: "#bac2de"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                                visible: text !== ""
                            }
                            
                            // Actions list (if any)
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                spacing: 8
                                visible: modelData.actions && modelData.actions.length > 0
                                
                                Repeater {
                                    model: modelData.actions
                                    
                                    delegate: Rectangle {
                                        required property var modelData
                                        
                                        width: actText.implicitWidth + 24
                                        height: 24
                                        color: actMouse.containsMouse ? "#313244" : "#1e1e2e"
                                        border.color: actMouse.containsMouse ? "#89b4fa" : "#313244"
                                        border.width: 1
                                        radius: 4
                                        
                                        Text {
                                            id: actText
                                            anchors.centerIn: parent
                                            text: modelData.text || "Action"
                                            color: actMouse.containsMouse ? "#89b4fa" : "#cdd6f4"
                                            font.family: "JetBrainsMono Nerd Font Propo"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            id: actMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Right side: Close Button
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: closeMouse.containsMouse ? "#313244" : "transparent"
                            Layout.alignment: Qt.AlignTop
                            
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: closeMouse.containsMouse ? "#f38ba8" : "#585b70"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: modelData.tracked = false
                            }
                        }
                    }
                }
            }
        }
    }
}
