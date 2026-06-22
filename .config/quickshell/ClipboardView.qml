import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FocusScope {
    id: viewRoot
    
    property string searchText: ""
    property var clipboardItems: []
    signal closed()
    
    function forceFocus() {
        searchInput.forceActiveFocus();
    }
    
    function reset() {
        searchText = "";
        searchInput.text = "";
        appsList.currentIndex = 0;
        loadClipboard();
    }
    
    function loadClipboard() {
        listProcess.exec(["cliphist", "list"]);
    }
    
    // Process to list clipboard history
    Process {
        id: listProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var outputText = text;
                var lines = outputText.split("\n");
                var items = [];
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (!line) continue;
                    
                    var tabIdx = line.indexOf("\t");
                    if (tabIdx === -1) {
                        tabIdx = line.indexOf(" ");
                    }
                    if (tabIdx === -1) continue;
                    
                    var id = line.substring(0, tabIdx);
                    var textVal = line.substring(tabIdx + 1);
                    items.push({ id: id, text: textVal });
                }
                viewRoot.clipboardItems = items;
            }
        }
    }
    
    // Process to copy selected item
    Process {
        id: copyProcess
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
                        text: "Search clipboard..."
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
                                var selectedItem = appListModel[appsList.currentIndex];
                                if (selectedItem) {
                                    copyProcess.exec(["sh", "-c", "cliphist decode " + selectedItem.id + " | wl-copy"]);
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
                var items = viewRoot.clipboardItems;
                var query = viewRoot.searchText.toLowerCase().trim();
                if (!query) {
                    return items;
                }
                
                return items.filter(item => {
                    return item.text.toLowerCase().includes(query);
                });
            })()
            
            delegate: Rectangle {
                required property var modelData
                required property int index
                
                width: appsList.width
                height: 40
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
                    
                    // Clipboard Icon
                    Text {
                        text: ""
                        color: ListView.isCurrentItem ? "#89b4fa" : "#a6adc8"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 14
                    }
                    
                    // Clip Content (strictly single line, truncated with ellipsis)
                    Text {
                        text: modelData.text
                        color: ListView.isCurrentItem ? "#89b4fa" : "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        wrapMode: Text.NoWrap
                        Layout.fillWidth: true
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: appsList.currentIndex = index
                    onClicked: {
                        copyProcess.exec(["sh", "-c", "cliphist decode " + modelData.id + " | wl-copy"]);
                        viewRoot.closed();
                    }
                }
            }
        }
    }
}
