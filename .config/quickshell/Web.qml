pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "Singletons"

/**
 * Web-app launcher surface. Ported from the old config's WebView.qml but
 * re-skinned to use the Ricelin template's PillSurface style, Theme tokens
 * and Motion animations.
 *
 * Searches the configured list of websites; Enter/click opens or focuses
 * the app window in Niri, or launches Chromium in --app mode.
 */
PillSurface {
    id: root

    mTop: 14
    mLeft: 14
    mRight: 14
    mBottom: 14

    implicitHeight: content.implicitHeight

    ameForm: "off"
    amePoint: Qt.point(0, 0)

    readonly property var webData: [
        { name: "Gemini",     url: "https://gemini.google.com/app",           icon: "sparkles" },
        { name: "YouTube",    url: "https://youtube.com/",                    icon: "video" },
        { name: "Claude",     url: "https://claude.ai/new",                   icon: "sparkles" },
        { name: "DeepSeek",   url: "https://chat.deepseek.com/",              icon: "sparkles" },
        { name: "ChatGPT",    url: "https://chatgpt.com/?temporary-chat=true",icon: "sparkles" },
        { name: "Perplexity", url: "https://www.perplexity.ai/",              icon: "globe" },
        { name: "X",          url: "https://x.com/",                         icon: "globe" },
        { name: "Reddit",     url: "https://reddit.com/",                     icon: "globe" },
        { name: "Keep",       url: "https://keep.google.com/",                icon: "clipboard" },
        { name: "Gmail",      url: "https://mail.google.com/",                icon: "inbox" }
    ]

    property string query: ""

    readonly property var filtered: {
        var q = query.toLowerCase().trim();
        if (!q) return webData;
        return webData.filter(function(item) {
            return item.name.toLowerCase().includes(q) || item.url.toLowerCase().includes(q);
        });
    }

    Process { id: openProc }

    function launchUrl(url) {
        var cmd = "url=\"" + url + "\"; domain=$(echo \"$url\" | sed -E 's|https?://||; s|/.*||');"
            + " wid=$(niri msg -j windows | jq -r --arg d \"$domain\" '.[] | select(.app_id | contains($d)) | .id' | head -n1);"
            + " if [ -n \"$wid\" ]; then niri msg action focus-window --id \"$wid\"; else chromium --app=\"$url\"; fi";
        openProc.exec(["bash", "-c", cmd]);
        root.requestClose();
    }

    onActiveChanged: if (!active) { query = ""; searchField.clear(); }

    Column {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10 * root.s

        SettingsHeader {
            s: root.s
            glyph: "網"
            icon: "globe"
            title: "WEB"
        }

        // Search bar
        Rectangle {
            width: parent.width
            height: 36 * root.s
            radius: 8 * root.s
            color: Theme.tileBg
            border.width: 1
            border.color: searchField.activeFocus ? Theme.vermLit : Theme.border

            Behavior on border.color { ColorAnimation { duration: Motion.fast } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10 * root.s
                anchors.rightMargin: 10 * root.s
                spacing: 8 * root.s

                GlyphIcon {
                    width: 14 * root.s
                    height: 14 * root.s
                    name: "search"
                    color: searchField.activeFocus ? Theme.vermLit : Theme.iconDim
                    stroke: 1.8
                }

                TextInput {
                    id: searchField
                    Layout.fillWidth: true
                    color: Theme.cream
                    font.family: Theme.font
                    font.pixelSize: 13 * root.s
                    clip: true
                    focus: root.active

                    onTextChanged: root.query = text

                    function clear() { text = ""; }

                    // Placeholder
                    Text {
                        visible: searchField.text === ""
                        text: "Search websites..."
                        color: Theme.faint
                        font: searchField.font
                    }

                    Keys.onEscapePressed: root.requestClose()
                    Keys.onReturnPressed: {
                        if (webList.currentIndex >= 0 && webList.currentIndex < root.filtered.length)
                            root.launchUrl(root.filtered[webList.currentIndex].url);
                    }
                    Keys.onPressed: (e) => {
                        if (e.key === Qt.Key_Down) {
                            webList.currentIndex = Math.min(webList.currentIndex + 1, webList.count - 1);
                            e.accepted = true;
                        } else if (e.key === Qt.Key_Up) {
                            webList.currentIndex = Math.max(webList.currentIndex - 1, 0);
                            e.accepted = true;
                        }
                    }
                }
            }
        }

        // Results list
        ListView {
            id: webList
            width: parent.width
            height: Math.min(root.filtered.length, 6) * 44 * root.s
            clip: true
            spacing: 3 * root.s
            currentIndex: 0
            model: root.filtered

            delegate: Rectangle {
                id: webItem
                required property var modelData
                required property int index

                width: webList.width
                height: 44 * root.s
                radius: 8 * root.s
                color: webItem.index === webList.currentIndex
                    ? Qt.alpha(Theme.vermLit, 0.12) : (area.containsMouse ? Theme.frameBg : "transparent")
                border.width: 1
                border.color: webItem.index === webList.currentIndex
                    ? Qt.alpha(Theme.vermLit, 0.4) : "transparent"

                Behavior on color { ColorAnimation { duration: Motion.fast } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10 * root.s
                    anchors.rightMargin: 10 * root.s
                    spacing: 10 * root.s

                    GlyphIcon {
                        width: 16 * root.s
                        height: 16 * root.s
                        name: webItem.modelData.icon
                        color: webItem.index === webList.currentIndex ? Theme.vermLit : Theme.iconDim
                        stroke: 1.7
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 1 * root.s
                        Text {
                            text: webItem.modelData.name
                            color: webItem.index === webList.currentIndex ? Theme.cream : Theme.subtle
                            font.family: Theme.font
                            font.pixelSize: 13 * root.s
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: webItem.modelData.url
                            color: Theme.faint
                            font.family: Theme.font
                            font.pixelSize: 9.5 * root.s
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: webList.currentIndex = webItem.index
                    onClicked: root.launchUrl(webItem.modelData.url)
                }
            }
        }
    }
}
