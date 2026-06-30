import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FocusScope {
    id: viewRoot
    
    signal closed()
    
    property bool confirmMode: false
    property var selectedItem: null
    property int confirmIndex: 1 // 0 = Yes, 1 = No (default to safe 'No')
    property int currentIndex: 0
    
    property var powerItems: [
        { name: "Lock", icon: "", cmd: "loginctl lock-session", confirm: false, color: "#89b4fa" },
        { name: "Suspend", icon: "󰤄", cmd: "systemctl suspend", confirm: true, color: "#f9e2af" },
        { name: "Logout", icon: "", cmd: "pgrep -x i3 > /dev/null && i3-msg exit || loginctl terminate-session $XDG_SESSION_ID", confirm: true, color: "#a6e3a1" },
        { name: "Reboot", icon: "", cmd: "systemctl reboot", confirm: true, color: "#fab387" },
        { name: "Shutdown", icon: "", cmd: "systemctl poweroff", confirm: true, color: "#f38ba8" }
    ]
    
    function forceFocus() {
        viewRoot.forceActiveFocus();
    }
    
    function reset() {
        confirmMode = false;
        selectedItem = null;
        confirmIndex = 1;
        currentIndex = 0;
    }
    
    Process {
        id: runProcess
    }
    
    function executeCommand(cmd) {
        runProcess.exec(["bash", "-c", cmd]);
        viewRoot.closed();
    }
    
    Keys.onPressed: (event) => {
        var isLeft = event.key === Qt.Key_Left || event.key === Qt.Key_Up || (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier));
        var isRight = event.key === Qt.Key_Right || event.key === Qt.Key_Down || (event.key === Qt.Key_J && (event.modifiers & Qt.ControlModifier));
        
        if (confirmMode) {
            if (isLeft || isRight) {
                confirmIndex = confirmIndex === 0 ? 1 : 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (confirmIndex === 0) {
                    executeCommand(selectedItem.cmd);
                } else {
                    confirmMode = false;
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                confirmMode = false;
                event.accepted = true;
            }
        } else {
            if (isRight) {
                currentIndex = Math.min(currentIndex + 1, powerItems.length - 1);
                event.accepted = true;
            } else if (isLeft) {
                currentIndex = Math.max(currentIndex - 1, 0);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                var item = powerItems[currentIndex];
                if (item.confirm) {
                    selectedItem = item;
                    confirmIndex = 1; // default to No
                    confirmMode = true;
                } else {
                    executeCommand(item.cmd);
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                viewRoot.closed();
                event.accepted = true;
            }
        }
    }
    
    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12
        
        // Header Title
        Text {
            text: confirmMode ? "CONFIRM ACTION" : "POWER MENU"
            color: "#585b70"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 11
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        // Horizontal Power Options Layout
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 56
            visible: !confirmMode
            spacing: 16
            
            Repeater {
                model: powerItems
                delegate: Rectangle {
                    Layout.preferredWidth: 54
                    Layout.preferredHeight: 54
                    radius: 27
                    
                    color: index === currentIndex ? "#313244" : "transparent"
                    border.color: index === currentIndex ? modelData.color : "transparent"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: index === currentIndex ? modelData.color : "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 22
                        
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: currentIndex = index
                        onClicked: {
                            if (modelData.confirm) {
                                selectedItem = modelData;
                                confirmIndex = 1;
                                confirmMode = true;
                            } else {
                                executeCommand(modelData.cmd);
                            }
                        }
                    }
                }
            }
        }
        
        // Active Option Label
        Text {
            visible: !confirmMode
            text: powerItems[currentIndex].name.toUpperCase()
            color: powerItems[currentIndex].color
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
        
        // Confirmation View
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: confirmMode
            spacing: 14
            
            Text {
                text: "Are you sure you want to " + (selectedItem ? selectedItem.name.toLowerCase() : "") + "?"
                color: "#cdd6f4"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                // Yes button
                Rectangle {
                    width: 110
                    height: 38
                    radius: 6
                    color: confirmIndex === 0 ? "#f38ba8" : "#313244"
                    border.color: confirmIndex === 0 ? "#f38ba8" : "transparent"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Yes"
                        color: confirmIndex === 0 ? "#11111b" : "#f38ba8"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: confirmIndex = 0
                        onClicked: {
                            if (selectedItem) {
                                executeCommand(selectedItem.cmd);
                            }
                        }
                    }
                }
                
                // No button
                Rectangle {
                    width: 110
                    height: 38
                    radius: 6
                    color: confirmIndex === 1 ? "#a6e3a1" : "#313244"
                    border.color: confirmIndex === 1 ? "#a6e3a1" : "transparent"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "No"
                        color: confirmIndex === 1 ? "#11111b" : "#a6e3a1"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: confirmIndex = 1
                        onClicked: confirmMode = false
                    }
                }
            }
        }
    }
}
