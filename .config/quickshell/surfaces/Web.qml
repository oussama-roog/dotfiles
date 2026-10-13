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

    implicitHeight: search.height + 8 * s + list.height

    readonly property var sites: [
        { name: "Gemini",     url: "https://gemini.google.com/app",            icon: Icons.sparkle },
        { name: "YouTube",    url: "https://youtube.com/",                     icon: Icons.youtube },
        { name: "Claude",     url: "https://claude.ai/new",                    icon: Icons.sparkle },
        { name: "DeepSeek",   url: "https://chat.deepseek.com/",               icon: Icons.brain },
        { name: "ChatGPT",    url: "https://chatgpt.com/?temporary-chat=true", icon: Icons.openai },
        { name: "Perplexity", url: "https://www.perplexity.ai/",               icon: Icons.search },
        { name: "X",          url: "https://x.com/",                           icon: Icons.xLogo },
        { name: "Reddit",     url: "https://reddit.com/",                      icon: Icons.reddit },
        { name: "Keep",       url: "https://keep.google.com/",                 icon: Icons.note },
        { name: "Gmail",      url: "https://mail.google.com/",                 icon: Icons.envelope },
        { name: "Satim Mail", url: "https://mail.satim.dz/",                   icon: Icons.envelope }
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
        icon: Icons.globe
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

    ListView {
        id: list
        anchors.top: search.bottom
        anchors.topMargin: 8 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(1, root.results.length) * 40 * root.s
        spacing: 2 * root.s
        interactive: false
        model: root.results

        ElasticHighlight {
            parent: list.contentItem
            z: -1
            tx: 0
            ty: root.selectedIndex * (38 * root.s + list.spacing)
            tw: list.width
            th: 38 * root.s
            radius: 12 * root.s
            shown: root.results.length > 0
        }

        delegate: Item {
            id: row
            required property var modelData
            required property int index
            readonly property bool selected: index === root.selectedIndex

            width: list.width
            height: 38 * root.s

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedIndex = row.index
                onClicked: root.activate()
            }

            Icon {
                id: siteIcon
                anchors.left: parent.left
                anchors.leftMargin: 14 * root.s
                anchors.verticalCenter: parent.verticalCenter
                size: 18 * root.s
                text: row.modelData.icon
                color: row.selected ? Theme.onAccent : Theme.icon
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
                    color: row.selected ? Theme.onAccent : Theme.textSubtle
                    font.family: Theme.font
                    font.pixelSize: 13 * root.s
                    font.weight: row.selected ? Font.DemiBold : Font.Normal
                }
                Text {
                    width: parent.width
                    text: row.modelData.url
                    color: row.selected ? Qt.alpha(Theme.onAccent, 0.65) : Theme.textFaint
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
