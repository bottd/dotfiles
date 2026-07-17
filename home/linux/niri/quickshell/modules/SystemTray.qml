import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    id: root

    required property var parentWindow

    spacing: 8

    Repeater {
        model: SystemTray.items

        delegate: IconImage {
            required property var modelData

            implicitWidth: 16
            implicitHeight: 16
            source: modelData.icon

            MouseArea {
                anchors.fill: parent
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
        }
    }
}
