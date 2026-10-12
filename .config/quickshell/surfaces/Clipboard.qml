pragma ComponentBehavior: Bound

import QtQuick
import "../services"
import "../widgets"

/**
 * Clipboard surface: search field over the cliphist history, drawn as one of
 * the pill's surfaces. Entries come from the Cliphist singleton snapshot so the
 * list is populated as soon as the pill finishes morphing. Typing filters by
 * substring, Return copies the selected entry and closes, hovering a row
 * cross-fades a dismiss glyph that deletes it (Ctrl+X does the same for the
 * keyboard selection). Image entries render their cached thumbnail beside the
 * size label. Holding the trash (or 掃) glyph for the heat duration wipes the
 * whole history; progress sweeps along under the search field and drains on
 * early release.
 */
PillSurface {
    id: root

    mTop: 15
    mLeft: 17
    mRight: 17
    mBottom: 14

    property string query: ""
    property int selectedIndex: 0

    /**
     * Window-coordinate position of the last hover event that was allowed to
     * move the selection. Rows sliding under a stationary cursor during
     * keyboard scrolling produce hover events at an unchanged window position,
     * which must not steal the keyboard selection.
     */
    property point lastPointer: Qt.point(-1, -1)

    readonly property var results: {
        var all = Cliphist.entries;
        var q = query.trim().toLowerCase();
        if (!q.length)
            return all;
        var out = [];
        for (var i = 0; i < all.length; i++) {
            var hay = (all[i].isImage ? all[i].label + " " + all[i].sizeLabel : all[i].preview).toLowerCase();
            if (hay.indexOf(q) !== -1)
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
        Cliphist.copy(results[selectedIndex]);
        root.requestClose();
    }

    function rowH(entry) {
        return (entry && entry.isImage ? 44 : 28) * s;
    }

    /** Top of row `index` in the list, for the sliding highlight. */
    function rowY(index) {
        var y = 0;
        for (var i = 0; i < index && i < results.length; i++)
            y += rowH(results[i]) + list.spacing;
        return y;
    }

    function removeAt(index) {
        if (index < 0 || index >= results.length)
            return;
        Cliphist.remove(results[index]);
    }

    onOpenChanged: {
        if (open) {
            query = "";
            search.text = "";
            selectedIndex = 0;
            Cliphist.refresh();
            Qt.callLater(root.focusField);
        }
    }
    onResultsChanged: if (selectedIndex >= results.length) selectedIndex = Math.max(0, results.length - 1)

    SearchField {
        id: search
        z: 5
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        s: root.s
        kanji: "控"
        placeholder: "Search clipboard"
        counterText: root.results.length + " / " + Cliphist.count
        onTextChanged: {
            root.query = text;
            root.selectedIndex = 0;
        }
        onMoved: (d) => root.move(d)
        onAccepted: root.activate()
        onDismissed: root.requestClose()
        onKeyPressed: (e) => {
            if (e.key === Qt.Key_X && (e.modifiers & Qt.ControlModifier)
                && search.input.selectedText.length === 0) {
                root.removeAt(root.selectedIndex);
                e.accepted = true;
            }
        }

        Item {
            id: wipeBtn
            anchors.verticalCenter: parent.verticalCenter
            width: 16 * root.s
            height: 16 * root.s

            readonly property real hold: wipeHeat.hold
            readonly property bool holding: wipeHeat.holding
            readonly property color tone: holding ? Theme.accent : (wipeArea.containsMouse ? Theme.text : Theme.textFaint)

            Tooltip {
                s: root.s
                placement: "below"
                title: "hold to wipe"
                show: wipeArea.containsMouse || wipeBtn.holding
            }

            Text {
                visible: Flags.showGlyphs
                anchors.centerIn: parent
                text: "掃"
                color: wipeBtn.tone
                font.family: Theme.fontJp
                font.pixelSize: 12 * root.s
                Behavior on color { ColorAnimation { duration: Motion.fast } }
            }

            Icon {
                visible: !Flags.showGlyphs
                anchors.centerIn: parent
                size: 14 * root.s
                text: Icons.trash
                color: wipeBtn.tone
            }

            HeatHold {
                id: wipeHeat
                onConfirmed: Cliphist.wipe()
            }

            MouseArea {
                id: wipeArea
                anchors.fill: parent
                anchors.margins: -5 * root.s
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: wipeHeat.press()
                onReleased: wipeHeat.release()
                onExited: wipeHeat.cancel()
            }
        }
    }

    Rectangle {
        id: divider
        anchors.top: search.bottom
        anchors.topMargin: 4 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 14 * root.s
        anchors.rightMargin: 14 * root.s
        height: 2 * root.s
        radius: height / 2
        color: "transparent"

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.width * wipeBtn.hold
            visible: wipeBtn.holding
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.alpha(Theme.accent, 0.15) }
                GradientStop { position: 1.0; color: Theme.accent }
            }
        }
    }

    Text {
        anchors.centerIn: list
        visible: root.results.length === 0
        text: root.query.length ? "No matches" : "History empty"
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: 10.5 * root.s
    }

    ListView {
        id: list
        anchors.top: divider.bottom
        anchors.topMargin: 2 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 2 * root.s
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: root.results.length

        ElasticHighlight {
            parent: list.contentItem
            z: -1
            tx: 0
            ty: root.rowY(root.selectedIndex)
            tw: list.width
            th: root.rowH(root.results[root.selectedIndex])
            radius: 10 * root.s
            shown: root.results.length > 0
        }

        delegate: Item {
            id: row
            required property int index
            width: list.width
            height: root.rowH(entry)

            readonly property var entry: root.results[index]
            readonly property bool selected: index === root.selectedIndex

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

            MouseArea {
                id: rowArea
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

                Rectangle {
                    id: thumbTile
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.entry !== undefined && row.entry.isImage
                    width: visible ? 52 * root.s : 0
                    height: 32 * root.s
                    radius: 6 * root.s
                    color: Theme.tileBg
                    border.width: 1
                    border.color: Theme.border
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: thumbTile.visible ? "file://" + row.entry.thumb : ""
                        sourceSize.width: 128
                        sourceSize.height: 128
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: thumbTile.visible ? thumbTile.right : parent.left
                    anchors.leftMargin: thumbTile.visible ? 9 * root.s : 0
                    anchors.right: sizeTag.left
                    anchors.rightMargin: 8 * root.s
                    text: row.entry === undefined ? "" : (row.entry.isImage ? row.entry.label : row.entry.preview)
                    color: row.selected ? Theme.onAccent
                        : (row.entry !== undefined && row.entry.isImage ? Theme.textFaint : Theme.textSubtle)
                    font.family: Theme.font
                    font.pixelSize: 11.5 * root.s
                    font.weight: row.selected ? Font.DemiBold : Font.Medium
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                }

                Text {
                    id: sizeTag
                    anchors.right: tail.left
                    anchors.rightMargin: width > 0 ? 8 * root.s : 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.entry !== undefined && row.entry.isImage ? row.entry.sizeLabel : ""
                    width: text.length ? implicitWidth : 0
                    color: row.selected ? Qt.alpha(Theme.onAccent, 0.65) : Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 10.5 * root.s
                    font.features: { "tnum": 1 }
                }

                Item {
                    id: tail
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(ret.implicitWidth, dismiss.implicitWidth)
                    height: Math.max(ret.implicitHeight, dismiss.implicitHeight)

                    Text {
                        id: ret
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: row.selected && !rowHover.hovered ? 1 : 0
                        text: "↵"
                        color: Theme.onAccent
                        font.family: Theme.font
                        font.pixelSize: 12 * root.s
                        Behavior on opacity { NumberAnimation { duration: Motion.fast } }
                    }

                    Icon {
                        id: dismiss
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: rowHover.hovered ? 1 : 0
                        size: 12 * root.s
                        text: Icons.close
                        color: row.selected ? Theme.onAccent : (dismissArea.containsMouse ? Theme.text : Theme.textDim)
                        Behavior on opacity { NumberAnimation { duration: Motion.fast } }

                        MouseArea {
                            id: dismissArea
                            anchors.fill: parent
                            anchors.margins: -6 * root.s
                            enabled: rowHover.hovered
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.removeAt(row.index)
                        }
                    }
                }
            }
        }
    }
}
