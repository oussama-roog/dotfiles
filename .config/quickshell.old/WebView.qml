import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FocusScope {
    id: viewRoot
    
    property string searchText: ""
    signal closed()
    
    // Website list data
    property var webData: [
        { name: "Perplexity", url: "https://www.perplexity.ai/", icon: "󰧑" },
        { name: "Gemini", url: "https://gemini.google.com/app", icon: "󱚝" },
        { name: "Claude", url: "https://claude.ai/new", icon: "󰧑" },
        { name: "ChatGPT", url: "https://chatgpt.com/?temporary-chat=true", icon: "󰧑" },
        { name: "DeepSeek", url: "https://chat.deepseek.com/", icon: "󰧑" },
        { name: "Youtube", url: "https://youtube.com/", icon: "󰗃" },
        { name: "X", url: "https://x.com/", icon: "󰗪" },
        { name: "Reddit", url: "https://reddit.com/", icon: "" },
        { name: "keep", url: "https://keep.google.com/", icon: "󱞎" },
        { name: "Gmail", url: "https://mail.google.com/", icon: "" }
    ]
    
    function forceFocus() {
        searchInput.forceActiveFocus();
    }
    
    function reset() {
        searchText = "";
        searchInput.text = "";
        webList.currentIndex = 0;
    }
    
    Process {
        id: openProcess
    }
    
    function launchUrl(url) {
        var cmd = "url=\"" + url + "\"; domain=$(echo \"$url\" | sed -E 's|https?://||; s|/.*||'); window_id=$(niri msg -j windows | jq -r --arg domain \"$domain\" '.[] | select(.app_id | contains($domain)) | .id' | head -n1); if [[ -n \"$window_id\" ]]; then niri msg action focus-window --id \"$window_id\"; else chromium --app=\"$url\"; fi";
        openProcess.exec(["bash", "-c", cmd]);
        viewRoot.closed();
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
                        text: "Select Website..."
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
                            webList.currentIndex = Math.min(webList.currentIndex + 1, webList.count - 1);
                            webList.positionViewAtIndex(webList.currentIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up || isCtrlK) {
                            webList.currentIndex = Math.max(webList.currentIndex - 1, 0);
                            webList.positionViewAtIndex(webList.currentIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            var listModel = webList.model;
                            if (listModel && listModel.length > 0 && webList.currentIndex >= 0) {
                                var selectedItem = listModel[webList.currentIndex];
                                if (selectedItem) {
                                    viewRoot.launchUrl(selectedItem.url);
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
            id: webList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            
            // Real-time filtered model
            model: (() => {
                var items = viewRoot.webData;
                var query = viewRoot.searchText.toLowerCase().trim();
                if (!query) {
                    return items;
                }
                
                return items.filter(item => {
                    return item.name.toLowerCase().includes(query) || item.url.toLowerCase().includes(query);
                });
            })()
            
            delegate: Rectangle {
                required property var modelData
                required property int index
                
                width: webList.width
                height: 48
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
                    
                    // Web Icon
                    Text {
                        text: modelData.icon
                        color: ListView.isCurrentItem ? "#89b4fa" : "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 18
                        Layout.preferredWidth: 24
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Web Name
                    Text {
                        text: modelData.name
                        color: ListView.isCurrentItem ? "#89b4fa" : "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    // Spacer
                    Item { Layout.fillWidth: true }
                    
                    // Web URL Hint
                    Text {
                        text: modelData.url
                        color: ListView.isCurrentItem ? "#bac2de" : "#585b70"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 11
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: webList.currentIndex = index
                    onClicked: {
                        viewRoot.launchUrl(modelData.url);
                    }
                }
            }
        }
    }
}
