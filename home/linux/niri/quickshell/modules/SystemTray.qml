import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    id: root

    required property var parentWindow
    required property var theme
    property bool overlayOpen: false
    onOverlayOpenChanged: {
        if (overlayOpen)
            trayMenu.close();
    }

    spacing: Math.round(theme.fontSize / 3) // 4

    TrayMenu {
        id: trayMenu
        screen: root.parentWindow.screen
        theme: root.theme
    }

    Repeater {
        model: SystemTray.items

        // Icons keep their own colour (DESIGN.md: App Identity Exception);
        // the slug around them speaks press. Attention prints a danger plate.
        delegate: Item {
            id: trayItem

            required property var modelData
            readonly property string itemName: modelData.tooltipTitle || modelData.title || modelData.id || "System tray item"
            readonly property string toolTipText: modelData.tooltipDescription ? itemName + "\n" + modelData.tooltipDescription : itemName
            readonly property bool needsAttention: modelData.status === Status.NeedsAttention

            implicitWidth: root.theme.controlSize
            implicitHeight: root.theme.controlSize
            Accessible.role: Accessible.Button
            Accessible.name: itemName + (needsAttention ? ", needs attention" : "")

            Rectangle {
                visible: trayItem.needsAttention
                x: root.theme.plateOffset
                y: root.theme.plateOffset
                width: slug.width
                height: slug.height
                color: root.theme.danger
            }

            Rectangle {
                id: slug

                x: trayMouse.pressed ? root.theme.plateOffset : 0
                y: x
                width: parent.width - root.theme.plateOffset
                height: parent.height - root.theme.plateOffset
                radius: root.theme.radius
                color: root.theme.background
                border.color: trayItem.needsAttention ? root.theme.danger : root.theme.ink
                border.width: trayMouse.containsMouse || trayItem.needsAttention ? root.theme.ruleWidth : 0

                IconImage {
                    anchors.centerIn: parent
                    implicitWidth: root.theme.iconSize
                    implicitHeight: root.theme.iconSize
                    source: trayItem.modelData.icon
                }
            }

            MouseArea {
                id: trayMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                // An icon-only tray item's name exists nowhere but its tooltip.
                onPressAndHold: trayTip.pinned = true
                onClicked: function (mouse) {
                    if (modelData.hasMenu && (modelData.onlyMenu || mouse.button === Qt.RightButton)) {
                        trayMenu.show(modelData);
                    } else if (mouse.button === Qt.MiddleButton)
                        modelData.secondaryActivate();
                    else
                        modelData.activate();
                }
            }

            BarTooltip {
                id: trayTip

                anchorItem: trayItem
                theme: root.theme
                text: toolTipText
                show: trayMouse.containsMouse
            }
        }
    }
}
