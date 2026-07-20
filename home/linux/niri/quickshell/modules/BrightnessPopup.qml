import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var theme
    required property real level
    signal setBrightness(real level)
    signal dismissed

    anchors.bottom: true
    anchors.right: true
    margins.bottom: 48
    margins.right: 120
    implicitWidth: 240
    implicitHeight: 96
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "drake-brightness-popup"

    onScreenChanged: {
        if (root.visible)
            dismissTimer.restart();
    }

    function updateBrightness(x, width) {
        root.setBrightness(Math.max(0, Math.min(1, x / width)));
        dismissTimer.restart();
    }

    Timer {
        id: dismissTimer

        interval: 3000
        running: root.visible
        onTriggered: root.dismissed()
    }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: root.theme.base00
        border.color: root.theme.base02
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "󰃟 " + Math.round(root.level * 100) + "%"
                color: root.theme.base05
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                radius: 4
                clip: true
                color: root.theme.base02

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.level))
                    height: parent.height
                    radius: parent.radius
                    color: root.theme.base0D
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: function (mouse) {
                        root.updateBrightness(mouse.x, width);
                    }
                    onPositionChanged: function (mouse) {
                        if (pressed)
                            root.updateBrightness(mouse.x, width);
                    }
                }
            }
        }
    }
}
