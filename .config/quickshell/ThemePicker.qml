pragma ComponentBehavior: Bound

import QtQuick
import "Singletons"

/**
 * Theme surface: search field over every base16 scheme, drawn as one of the
 * pill's surfaces. Entries come from the Themes singleton snapshot; each row
 * previews the scheme with a swatch strip (background, foreground and the
 * accent slots). Typing filters by name, Return applies the selected scheme
 * through theme-switcher.sh and keeps the surface open so picks can be
 * iterated; the shell itself recolours live once the switcher lands. The
 * header button (or Ctrl+R) applies a random scheme.
 */
PillSurface {
    id: root

    mTop: 15
    mLeft: 17
    mRight: 17
    mBottom: 14

    property string query: ""
    property int selectedIndex: 0

    /** See Clipboard.qml: only real pointer motion may steal the selection. */
    property point lastPointer: Qt.point(-1, -1)

    readonly property var results: {
        var all = Themes.entries;
        var q = query.trim().toLowerCase();
        if (!q.length)
            return all;
        var out = [];
        for (var i = 0; i < all.length; i++) {
            if ((all[i].name + " " + all[i].id).toLowerCase().indexOf(q) !== -1)
                out.push(all[i]);
        }
        return out;
    }

    function focusField() { search.input.forceActiveFocus(); }

    function move(delta) {
        if (results.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
        list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function activate() {
        if (results.length === 0 || selectedIndex < 0 || selectedIndex >= results.length)
            return;
        Themes.apply(results[selectedIndex].id);
    }

    /** Start on the active scheme so the list opens where you left it. */
    function selectCurrent() {
        for (var i = 0; i < results.length; i++) {
            if (results[i].id === Themes.current) {
                selectedIndex = i;
                list.positionViewAtIndex(i, ListView.Beginning);
                return;
            }
        }
        selectedIndex = 0;
    }

    onActiveChanged: {
        if (active) {
            query = "";
            search.text = "";
            Themes.refresh();
            Qt.callLater(root.selectCurrent);
            Qt.callLater(root.focusField);
        }
    }
    onResultsChanged: {
        if (!query.length && active)
            selectCurrent();
        else if (selectedIndex >= results.length)
            selectedIndex = Math.max(0, results.length - 1);
    }

    SearchField {
        id: search
        z: 5
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        s: root.s
        kanji: "彩"
        icon: "palette"
        placeholder: "Search themes"
        counterText: root.results.length + " / " + Themes.count
        onTextChanged: {
            root.query = text;
            root.selectedIndex = 0;
        }
        onMoved: (d) => root.move(d)
        onAccepted: root.activate()
        onDismissed: root.requestClose()
        onKeyPressed: (e) => {
            if (e.key === Qt.Key_R && (e.modifiers & Qt.ControlModifier)) {
                Themes.random();
                e.accepted = true;
            }
        }

        Item {
            id: randomBtn
            anchors.verticalCenter: parent.verticalCenter
            width: 16 * root.s
            height: 16 * root.s

            readonly property color tone: Themes.applying ? Theme.vermLit
                : (randomArea.containsMouse ? Theme.cream : Theme.faint)

            Tooltip {
                s: root.s
                placement: "below"
                title: Themes.applying ? "applying…" : "random theme"
                show: randomArea.containsMouse
            }

            GlyphIcon {
                anchors.centerIn: parent
                width: 12 * root.s
                height: 12 * root.s
                name: "sparkles"
                color: randomBtn.tone
                Behavior on color { ColorAnimation { duration: Motion.fast } }
            }

            MouseArea {
                id: randomArea
                anchors.fill: parent
                anchors.margins: -5 * root.s
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Themes.random()
            }
        }
    }

    Rectangle {
        id: divider
        anchors.top: search.bottom
        anchors.topMargin: 8 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.hair

        /** Indeterminate sweep while theme-switcher.sh is running. */
        Rectangle {
            id: sweep
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.3
            visible: Themes.applying
            color: Theme.vermLit

            NumberAnimation on x {
                from: -sweep.width
                to: divider.width
                duration: 900
                loops: Animation.Infinite
                running: Themes.applying
            }
        }
    }

    Text {
        anchors.centerIn: list
        visible: root.results.length === 0
        text: Themes.count === 0 ? "Loading themes…" : "No matches"
        color: Theme.faint
        font.family: Theme.font
        font.pixelSize: 10.5 * root.s
    }

    ListView {
        id: list
        anchors.top: divider.bottom
        anchors.topMargin: 6 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 2 * root.s
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: root.results.length

        delegate: Item {
            id: row
            required property int index
            width: list.width
            height: 28 * root.s

            readonly property var entry: root.results[index]
            readonly property bool selected: index === root.selectedIndex
            readonly property bool isCurrent: entry !== undefined && entry.id === Themes.current

            HoverHandler {
                id: rowHover
                onPointChanged: {
                    if (!hovered)
                        return;
                    var sp = point.scenePosition;
                    if (sp.x !== root.lastPointer.x || sp.y !== root.lastPointer.y) {
                        root.lastPointer = Qt.point(sp.x, sp.y);
                        root.selectedIndex = row.index;
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 9 * root.s
                visible: row.selected || rowHover.hovered
                color: row.selected ? Theme.frameBg : Qt.alpha(Theme.cream, 0.03)
                border.width: row.selected ? 1 : 0
                border.color: Theme.frameBorder
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.selectedIndex = row.index;
                    root.activate();
                }
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 11 * root.s
                anchors.rightMargin: 11 * root.s

                /** Scheme preview: bg tile with the foreground and accents on it. */
                Rectangle {
                    id: swatch
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 64 * root.s
                    height: 14 * root.s
                    radius: 4 * root.s
                    color: row.entry ? row.entry.swatches[0] : "transparent"
                    border.width: 1
                    border.color: Theme.border

                    Row {
                        anchors.centerIn: parent
                        spacing: 2 * root.s

                        Repeater {
                            model: row.entry ? row.entry.swatches.slice(1) : []

                            Rectangle {
                                required property string modelData
                                width: 6 * root.s
                                height: 6 * root.s
                                radius: width / 2
                                color: modelData
                            }
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: swatch.right
                    anchors.leftMargin: 10 * root.s
                    anchors.right: tail.left
                    anchors.rightMargin: 8 * root.s
                    text: row.entry ? row.entry.name : ""
                    color: row.selected || row.isCurrent ? Theme.cream : Theme.subtle
                    font.family: Theme.font
                    font.pixelSize: 11.5 * root.s
                    font.weight: row.selected ? Font.DemiBold : Font.Medium
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                }

                Item {
                    id: tail
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12 * root.s
                    height: 12 * root.s

                    GlyphIcon {
                        anchors.centerIn: parent
                        width: 12 * root.s
                        height: 12 * root.s
                        visible: row.isCurrent
                        name: "check"
                        color: Theme.vermLit
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !row.isCurrent
                        opacity: row.selected && !rowHover.hovered ? 1 : 0
                        text: "↵"
                        color: Theme.vermLit
                        font.family: Theme.font
                        font.pixelSize: 12 * root.s
                        Behavior on opacity { NumberAnimation { duration: Motion.fast } }
                    }
                }
            }
        }
    }
}
