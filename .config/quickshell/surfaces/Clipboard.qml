pragma ComponentBehavior: Bound

import QtQuick
import "../services"
import "../widgets"

/**
 * Clipboard surface: search field over two columns, drawn as one of the pill's
 * surfaces. Left is the cliphist history from the Cliphist snapshot, one row
 * per entry led by a tile that says what it is (image thumbnail, colour swatch,
 * link or text glyph). Right previews the selected entry in full: the whole
 * text, wrapped (monospace once it spans lines), the image at size, or a big
 * swatch for a colour, with its stats in the header.
 *
 * Typing filters by substring, Return copies the selected entry and closes,
 * hovering a row cross-fades a dismiss glyph that deletes it (Ctrl+X does the
 * same for the keyboard selection). Holding the trash (or 掃) glyph for the heat
 * duration wipes the whole history; progress sweeps along under the search
 * field and drains on early release.
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

    readonly property var selected: results.length && selectedIndex < results.length ? results[selectedIndex] : null
    onSelectedChanged: if (open) Cliphist.show(selected)

    readonly property real rowH: 38 * s

    function focusField() { search.input.forceActiveFocus(); }

    function move(delta) {
        if (results.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
        list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function activate() {
        if (!selected)
            return;
        Cliphist.copy(selected);
        root.requestClose();
    }

    function removeAt(index) {
        if (index < 0 || index >= results.length)
            return;
        Cliphist.remove(results[index]);
    }

    function kindGlyph(kind) {
        return kind === "image" ? Icons.image : kind === "link" ? Icons.link : Icons.textLines;
    }

    function kindName(kind) {
        return kind === "image" ? "Image" : kind === "link" ? "Link" : kind === "color" ? "Colour" : "Text";
    }

    function plural(n, word) {
        return n + " " + word + (n === 1 ? "" : "s");
    }

    onOpenChanged: {
        if (open) {
            query = "";
            search.text = "";
            selectedIndex = 0;
            Cliphist.refresh();
            Cliphist.show(selected);
            Qt.callLater(root.focusField);
        }
    }
    onResultsChanged: if (selectedIndex >= results.length) selectedIndex = Math.max(0, results.length - 1)

    /** Small caps label, the inbox header's style. */
    component Label: Text {
        color: Theme.textSubtle
        font.family: Theme.font
        font.pixelSize: 9.5 * root.s
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1.5 * root.s
    }

    /** Keyboard hint in the preview footer: key cap plus what it does. */
    component Hint: Row {
        id: hint
        property string key: ""
        property string text: ""
        spacing: 5 * root.s

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(height, keyText.implicitWidth + 10 * root.s)
            height: 17 * root.s
            radius: 5 * root.s
            color: Theme.frameBg
            border.width: 1
            border.color: Theme.frameBorder

            Text {
                id: keyText
                anchors.centerIn: parent
                text: hint.key
                color: Theme.textSubtle
                font.family: Theme.font
                font.pixelSize: 9.5 * root.s
                font.weight: Font.DemiBold
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: hint.text
            color: Theme.textFaint
            font.family: Theme.font
            font.pixelSize: 10 * root.s
        }
    }

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

    Item {
        id: body
        anchors.top: divider.bottom
        anchors.topMargin: 6 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // ─── Left: history ───────────────────────────────────────────────────
        Item {
            id: left
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.round(parent.width * 0.42)

            Text {
                anchors.centerIn: parent
                visible: root.results.length === 0
                text: root.query.length ? "No matches" : "History empty"
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: 10.5 * root.s
            }

            ListView {
                id: list
                anchors.fill: parent
                spacing: 2 * root.s
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.results.length

                ElasticHighlight {
                    parent: list.contentItem
                    z: -1
                    tx: 0
                    ty: root.selectedIndex * (root.rowH + list.spacing)
                    tw: list.width
                    th: root.rowH
                    radius: 10 * root.s
                    shown: root.results.length > 0
                }

                delegate: Item {
                    id: row
                    required property int index
                    width: list.width
                    height: root.rowH

                    readonly property var entry: root.results[index]
                    readonly property bool selected: index === root.selectedIndex
                    readonly property string kind: entry ? entry.kind : "text"

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
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedIndex = row.index;
                            root.activate();
                        }
                    }

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 6 * root.s
                        anchors.rightMargin: 11 * root.s

                        /** What the entry is: thumbnail, swatch, or a kind glyph. */
                        Rectangle {
                            id: tile
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28 * root.s
                            height: width
                            radius: 8 * root.s
                            color: row.kind === "color" ? row.entry.preview.trim()
                                : row.selected ? Qt.alpha(Theme.onAccent, 0.14) : Theme.frameBg
                            border.width: 1
                            border.color: row.selected ? Qt.alpha(Theme.onAccent, 0.18) : Theme.frameBorder
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                visible: row.kind === "image"
                                source: visible ? "file://" + row.entry.thumb : ""
                                sourceSize.width: 96
                                sourceSize.height: 96
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true
                            }

                            Icon {
                                anchors.centerIn: parent
                                visible: row.kind === "text" || row.kind === "link"
                                size: 13 * root.s
                                text: root.kindGlyph(row.kind)
                                color: row.selected ? Theme.onAccent : Theme.icon
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: tile.right
                            anchors.leftMargin: 10 * root.s
                            anchors.right: sizeTag.left
                            anchors.rightMargin: 8 * root.s
                            text: !row.entry ? "" : row.entry.isImage ? row.entry.label : row.entry.preview.trim()
                            color: row.selected ? Theme.onAccent : Theme.text
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
                            text: row.entry && row.entry.isImage ? row.entry.sizeLabel : ""
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

            WheelScroller {
                anchors.fill: list
                s: root.s
                flick: list
            }
        }

        Rectangle {
            id: split
            anchors.left: left.right
            anchors.leftMargin: 12 * root.s
            anchors.top: parent.top
            anchors.topMargin: 4 * root.s
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4 * root.s
            width: 1
            color: Theme.hair
        }

        // ─── Right: preview ──────────────────────────────────────────────────
        Item {
            id: right
            anchors.left: split.right
            anchors.leftMargin: 14 * root.s
            anchors.right: parent.right
            anchors.rightMargin: 2 * root.s
            anchors.top: parent.top
            anchors.topMargin: 4 * root.s
            anchors.bottom: parent.bottom

            readonly property var e: root.selected
            readonly property string kind: e ? e.kind : ""
            /** The decoded entry is the selected one (not a stale previous load). */
            readonly property bool ready: e !== null && Cliphist.shownId === String(e.id)
            readonly property string fullText: ready ? Cliphist.shownText : (e && !e.isImage ? e.preview : "")
            readonly property bool multiline: fullText.indexOf("\n") !== -1
            readonly property string stats: {
                if (!e)
                    return "";
                if (e.isImage)
                    return e.label.replace(/^\w+/, m => m.toUpperCase()) + (e.sizeLabel ? "  ·  " + e.sizeLabel : "");
                if (!ready)
                    return "";
                var t = fullText;
                var words = t.trim().length ? t.trim().split(/\s+/).length : 0;
                return (Cliphist.shownTruncated ? "64 KiB+" : root.plural(t.length, "char"))
                    + "  ·  " + root.plural(words, "word")
                    + "  ·  " + root.plural(t.split("\n").length, "line");
            }

            visible: e !== null

            Item {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 18 * root.s

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6 * root.s

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 11 * root.s
                        text: right.kind === "color" ? Icons.palette : root.kindGlyph(right.kind)
                        color: Theme.accent
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.kindName(right.kind)
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: right.stats
                    color: Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 10 * root.s
                    font.features: { "tnum": 1 }
                }
            }

            Rectangle {
                id: frame
                anchors.top: header.bottom
                anchors.topMargin: 8 * root.s
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: footer.top
                anchors.bottomMargin: 10 * root.s
                radius: 12 * root.s
                color: Theme.frameBg
                border.width: 1
                border.color: Theme.frameBorder
                clip: true

                // Image: the full decode once it lands, the thumbnail until then.
                Image {
                    id: fullImage
                    anchors.fill: parent
                    anchors.margins: 10 * root.s
                    visible: right.kind === "image"
                    source: !visible ? "" : right.ready && Cliphist.shownImage.length ? Cliphist.shownImage : "file://" + right.e.thumb
                    sourceSize.width: Math.ceil(width * 2)
                    sourceSize.height: Math.ceil(height * 2)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    mipmap: true
                }

                // Colour: a big swatch over its value.
                Column {
                    anchors.centerIn: parent
                    visible: right.kind === "color"
                    spacing: 12 * root.s

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 96 * root.s
                        height: width
                        radius: 22 * root.s
                        color: right.kind === "color" ? right.e.preview.trim() : "transparent"
                        border.width: 1
                        border.color: Theme.frameBorder
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: right.kind === "color" ? right.e.preview.trim().toUpperCase() : ""
                        color: Theme.textBright
                        font.family: "monospace"
                        font.pixelSize: 15 * root.s
                        font.weight: Font.DemiBold
                    }
                }

                // Text and links: the whole thing, wrapped and scrollable.
                Flickable {
                    id: textFlick
                    anchors.fill: parent
                    anchors.margins: 12 * root.s
                    anchors.rightMargin: 8 * root.s
                    visible: right.kind === "text" || right.kind === "link"
                    contentHeight: bodyText.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentHeight > height

                    Connections {
                        target: root
                        function onSelectedChanged() { textFlick.contentY = 0; }
                    }

                    Text {
                        id: bodyText
                        width: textFlick.width - 4 * root.s
                        text: right.fullText
                        textFormat: Text.PlainText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: right.kind === "link" ? Theme.accent : Theme.text
                        font.family: right.multiline ? "monospace" : Theme.font
                        font.pixelSize: (right.multiline ? 11 : 13) * root.s
                        font.weight: right.multiline ? Font.Normal : Font.Medium
                        font.underline: right.kind === "link"
                        lineHeight: right.multiline ? 1.25 : 1.35
                    }

                    WheelScroller {
                        anchors.fill: parent
                        s: root.s
                        flick: textFlick
                    }
                }

                /** Fades the bottom edge when there is more text below. */
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    height: 28 * root.s
                    radius: frame.radius
                    visible: textFlick.visible && textFlick.contentHeight > textFlick.height
                        && textFlick.contentY + textFlick.height < textFlick.contentHeight - 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.alpha(Theme.tileBg, 0.85) }
                    }
                }
            }

            Item {
                id: footer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 18 * root.s

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14 * root.s

                    Hint { key: "↵"; text: "copy" }
                    Hint { key: "Ctrl X"; text: "delete" }
                    Hint { key: "Esc"; text: "close" }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: right.ready && Cliphist.shownTruncated
                    text: "showing the first 64 KiB"
                    color: Theme.textFaint
                    font.family: Theme.font
                    font.pixelSize: 10 * root.s
                }
            }
        }
    }
}
