pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "Singletons"

/**
 * Workspace dots for the pill, powered by Niri IPC via NiriSpaces singleton.
 * Active workspace is a wider filled dot (stick); the rest are small and dim,
 * brightening on hover. Clicking a dot focuses that workspace via niri msg.
 */
Item {
    id: workspaces

    property string screenName: ""
    property real s: 1
    property real stickW: 17 * s
    property real dotW: 5 * s
    property real gap: 4 * s

    readonly property var wsModel: NiriSpaces.workspaces

    readonly property int activeIndex: {
        for (var i = 0; i < wsModel.length; i++) {
            if (wsModel[i].is_active) return i;
        }
        return 0;
    }

    property int hoverIndex: -1

    /** Centre x of a dot slot (used by Ame soul bead). */
    function slotCenterX(idx) {
        var x = 0;
        for (var i = 0; i < idx; i++)
            x += (i === activeIndex ? stickW : dotW) + gap;
        return x + (idx === activeIndex ? stickW : dotW) / 2;
    }

    readonly property point activeDotPoint: {
        void workspaces.wsModel;
        void workspaces.activeIndex;
        return Qt.point(slotCenterX(Math.max(0, activeIndex)), height / 2);
    }

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Process {
        id: focusProc
    }

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: workspaces.gap

        Repeater {
            model: workspaces.wsModel

            delegate: Item {
                id: slot

                required property var modelData
                required property int index

                readonly property bool isActive: modelData.is_active

                Layout.preferredWidth: slot.isActive ? workspaces.stickW : workspaces.dotW
                Layout.preferredHeight: 22 * workspaces.s
                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: Motion.fast; easing.type: Motion.easeStandard }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: workspaces.dotW
                    radius: height / 2
                    color: slot.isActive ? Theme.vermLit : Theme.cream
                    opacity: slot.isActive ? 1.0 : (area.containsMouse ? 0.7 : 0.3)
                    Behavior on opacity { NumberAnimation { duration: Motion.fast } }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    anchors.leftMargin: -workspaces.gap / 2
                    anchors.rightMargin: -workspaces.gap / 2
                    anchors.topMargin: -8 * workspaces.s
                    anchors.bottomMargin: -8 * workspaces.s
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        focusProc.exec(["niri", "msg", "action", "focus-workspace", "--index",
                                        String(slot.modelData.idx)]);
                    }
                    onContainsMouseChanged: {
                        if (containsMouse)
                            workspaces.hoverIndex = slot.index;
                        else if (workspaces.hoverIndex === slot.index)
                            workspaces.hoverIndex = -1;
                    }
                }
            }
        }
    }
}
