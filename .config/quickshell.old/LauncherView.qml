import QtQuick
import QtQuick.Layouts
import Quickshell

FocusScope {
    id: viewRoot
    
    property string searchText: ""
    signal closed()
    
    function forceFocus() {
        searchInput.forceActiveFocus();
    }
    
    function reset() {
        searchText = "";
        searchInput.text = "";
        appsList.currentIndex = 0;
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        
        // Search Input Container
        Rectangle {
            Layout.fillWidth: true
            height: 46
            color: "#181825" // Catppuccin Mantle
            radius: 8
            border.color: searchInput.activeFocus ? "#89b4fa" : "#313244"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                
                // Search Icon
                Text {
                    text: ""
                    color: searchInput.activeFocus ? "#89b4fa" : "#a6adc8"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 16
                }
                
                // Text Input
                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: "#cdd6f4"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 14
                    clip: true
                    focus: true
                    
                    onTextChanged: viewRoot.searchText = text
                    
                    // Placeholder Text
                    Text {
                        text: "Search applications..."
                        color: "#585b70"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 14
                        visible: parent.text === ""
                    }
                    
                    // Keyboard Navigation
                    Keys.onPressed: (event) => {
                        var isCtrlJ = event.key === Qt.Key_J && (event.modifiers & Qt.ControlModifier);
                        var isCtrlK = event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier);
                        
                        if (event.key === Qt.Key_Down || isCtrlJ) {
                            appsList.currentIndex = Math.min(appsList.currentIndex + 1, appsList.count - 1);
                            appsList.positionViewAtIndex(appsList.currentIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up || isCtrlK) {
                            appsList.currentIndex = Math.max(appsList.currentIndex - 1, 0);
                            appsList.positionViewAtIndex(appsList.currentIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            var appListModel = appsList.model;
                            if (appListModel && appListModel.length > 0 && appsList.currentIndex >= 0) {
                                var selectedApp = appListModel[appsList.currentIndex];
                                if (selectedApp) {
                                    selectedApp.execute();
                                    viewRoot.closed();
                                }
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            viewRoot.closed();
                            event.accepted = true;
                        }
                    }
                }
            }
        }
        
        // List View
        ListView {
            id: appsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            
            // Real-time filtered model
            model: (() => {
                var apps = DesktopEntries.applications.values;
                // Sort alphabetically by name
                var sortedApps = [...apps].sort((a, b) => a.name.localeCompare(b.name));
                
                var query = viewRoot.searchText.toLowerCase().trim();
                if (!query) {
                    return sortedApps;
                }
                
                return sortedApps.filter(app => {
                    return app.name.toLowerCase().includes(query) ||
                           app.id.toLowerCase().includes(query) ||
                           (app.comment && app.comment.toLowerCase().includes(query)) ||
                           (app.genericName && app.genericName.toLowerCase().includes(query));
                });
            })()
            
            delegate: Rectangle {
                required property var modelData
                required property int index
                
                width: appsList.width
                height: 52
                radius: 6
                // Highlight selected item
                color: ListView.isCurrentItem ? "#313244" : "transparent"
                border.color: ListView.isCurrentItem ? "#89b4fa" : "transparent"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12
                    
                    // Icon image
                    Image {
                        width: 32
                        height: 32
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        
                        // Fallback if image fails to load
                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = Quickshell.iconPath("application-x-executable")
                            }
                        }
                    }
                    
                    // Name & Description
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: modelData.name
                            color: ListView.isCurrentItem ? "#89b4fa" : "#cdd6f4"
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.bold: true
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.comment || modelData.genericName || "Application"
                            color: "#a6adc8"
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: appsList.currentIndex = index
                    onClicked: {
                        modelData.execute();
                        viewRoot.closed();
                    }
                }
            }
        }
    }
}
