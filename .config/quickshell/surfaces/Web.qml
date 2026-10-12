pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../services"
import "../widgets"

/**
 * Web-app launcher surface: search over a fixed list of sites. Enter or a click
 * focuses the site's existing niri window, or opens it in Chromium --app mode.
 */
PillSurface {
    id: root

    mTop: 15
    mLeft: 11
    mRight: 11
    mBottom: 14

    implicitHeight: search.height + 15 * s + list.height

    readonly property var sites: [
        { name: "Gemini",     url: "https://gemini.google.com/app",            icon: "sparkles" },
        { name: "YouTube",    url: "https://youtube.com/",                     icon: "video" },
        { name: "Claude",     url: "https://claude.ai/new",                    icon: "sparkles" },
        { name: "DeepSeek",   url: "https://chat.deepseek.com/",               icon: "sparkles" },
        { name: "ChatGPT",    url: "https://chatgpt.com/?temporary-chat=true", icon: "sparkles" },
        { name: "Perplexity", url: "https://www.perplexity.ai/",               icon: "globe" },
        { name: "X",          url: "https://x.com/",                           icon: "globe" },
        { name: "Reddit",     url: "https://reddit.com/",                      icon: "globe" },
        { name: "Keep",       url: "https://keep.google.com/",                 icon: "clipboard" },
        { name: "Gmail",      url: "https://mail.google.com/",                 icon: "inbox" }
    ]

    property string query: ""
    property int selectedIndex: 0

    readonly property var results: {
        var q = query.trim().toLowerCase();
        if (!q)
            return sites;
        return sites.filter(item => item.name.toLowerCase().includes(q) || item.url.includes(q));
    }

    function move(delta) {
        if (results.length > 0)
            selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
    }

    function activate() {
        if (selectedIndex < 0 || selectedIndex >= results.length)
            return;
        Quickshell.execDetached(["bash", "-c",
            "domain=$(echo \"$1\" | sed -E 's|https?://||; s|/.*||'); "
            + "wid=$(niri msg -j windows | jq -r --arg d \"$domain\" '.[] | select(.app_id | contains($d)) | .id' | head -n1); "
            + "if [ -n \"$wid\" ]; then niri msg action focus-window --id \"$wid\"; else chromium --app=\"$1\"; fi",
            "_", results[selectedIndex].url]);
        root.requestClose();
    }

    onOpenChanged: if (open) {
        search.text = "";
        selectedIndex = 0;
        Qt.callLater(search.input.forceActiveFocus);
    }

    SearchField {
        id: search
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        s: root.s
        kanji: "網"
        icon: "globe"
        placeholder: "Search websites"
        counterText: root.results.length + " / " + root.sites.length
        onTextChanged: {
            root.query = text;
            root.selectedIndex = 0;
        }
        onMoved: (d) => root.move(d)
        onAccepted: root.activate()
        onDismissed: root.requestClose()
    }

    Rectangle {
        id: divider
        anchors.top: search.bottom
        anchors.topMargin: 8 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.hair
    }

    ListView {
        id: list
        anchors.top: divider.bottom
        anchors.topMargin: 6 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(1, root.results.length) * 40 * root.s
        spacing: 2 * root.s
        interactive: false
        model: root.results

        delegate: Item {
            id: row
            required property var modelData
            required property int index
            readonly property bool selected: index === root.selectedIndex

            width: list.width
            height: 38 * root.s

            Rectangle {
                anchors.fill: parent
                radius: 9 * root.s
                visible: row.selected
                color: Theme.frameBg
                border.width: 1
                border.color: Theme.frameBorder
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedIndex = row.index
                onClicked: root.activate()
            }

            GlyphIcon {
                id: siteIcon
                anchors.left: parent.left
                anchors.leftMargin: 14 * root.s
                anchors.verticalCenter: parent.verticalCenter
                width: 16 * root.s
                height: 16 * root.s
                name: row.modelData.icon
                color: row.selected ? Theme.accent : Theme.icon
                stroke: 1.7
            }

            Column {
                anchors.left: siteIcon.right
                anchors.leftMargin: 12 * root.s
                anchors.right: parent.right
                anchors.rightMargin: 11 * root.s
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1 * root.s

                Text {
                    width: parent.width
                    text: row.modelData.name
                    color: row.selected ? Theme.text : Theme.textSubtle
                    font.family: Theme.font
                    font.pixelSize: 13 * root.s
                    font.weight: row.selected ? Font.DemiBold : Font.Normal
                }
                Text {
                    width: parent.width
                    text: row.modelData.url
                    color: Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 10 * root.s
                    elide: Text.ElideRight
                }
            }
        }
    }

    Text {
        anchors.centerIn: list
        visible: root.results.length === 0
        text: "No matches"
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: 10.5 * root.s
    }
}
