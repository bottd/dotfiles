import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    id: root

    required property var parentWindow
    required property var theme

    spacing: 8

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayItem

            required property var modelData
            readonly property string itemName: modelData.tooltipTitle || modelData.title || modelData.id || "System tray item"
            readonly property string toolTipText: modelData.tooltipDescription ? itemName + "\n" + modelData.tooltipDescription : itemName
            readonly property bool needsAttention: modelData.status === Status.NeedsAttention

            implicitWidth: 28
            implicitHeight: 28
            radius: 4
            color: trayMouse.pressed ? root.theme.surfacePressed : (trayMouse.containsMouse || needsAttention ? root.theme.surfaceHover : "transparent")
            border.color: trayMouse.containsMouse ? root.theme.focusRing : (needsAttention ? root.theme.danger : "transparent")
            border.width: 1
            opacity: modelData.status === Status.Passive ? 0.65 : 1
            Accessible.role: Accessible.Button
            Accessible.name: itemName

            IconImage {
                anchors.centerIn: parent
                implicitWidth: 18
                implicitHeight: 18
                source: modelData.icon
                opacity: trayMouse.pressed ? 0.65 : 1
            }

            MouseArea {
                id: trayMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: function (mouse) {
                    if (modelData.hasMenu && (mouse.button === Qt.LeftButton || mouse.button === Qt.RightButton)) {
                        const point = root.parentWindow.contentItem.mapFromItem(parent, mouse.x, mouse.y);
                        modelData.display(root.parentWindow, point.x, point.y);
                    } else if (mouse.button === Qt.MiddleButton)
                        modelData.secondaryActivate();
                    else
                        modelData.activate();
                }
            }

            BarTooltip {
                anchorItem: trayItem
                theme: root.theme
                text: toolTipText
                show: trayMouse.containsMouse
            }
        }
    }
}
