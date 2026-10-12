pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias dnd: adapter.dnd
    property alias time12h: adapter.time12h
    property alias clockSeconds: adapter.clockSeconds
    property alias showGlyphs: adapter.showGlyphs
    property alias uiScale: adapter.uiScale
    property alias reduceMotion: adapter.reduceMotion
    property alias uiFont: adapter.uiFont
    property alias pillOpacity: adapter.pillOpacity

    FileView {
        id: file
        path: Quickshell.shellPath("flags.json")
        blockLoading: true
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: function(error) {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property bool dnd: false
            property bool time12h: false
            property bool clockSeconds: false
            property bool showGlyphs: false
            property real uiScale: 1.0
            property bool reduceMotion: false
            property string uiFont: ""
            property real pillOpacity: 1.0
        }
    }
}
