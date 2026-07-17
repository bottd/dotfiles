import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var theme
    required property real level
    required property bool muted
    signal setVolume(real level)
    signal toggleMute
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
    WlrLayershell.namespace: "drake-volume-popup"

    onScreenChanged: {
        if (root.visible)
            dismissTimer.restart();
    }

    function updateVolume(x, width) {
        root.setVolume(x / width);
        dismissTimer.restart();
    }

    component PopupText: Text {
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
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

            RowLayout {
                Layout.fillWidth: true

                PopupText {
                    Layout.fillWidth: true
                    text: root.muted ? "󰝟 muted" : "󰕾 " + Math.round(root.level * 100) + "%"
                }

                PopupText {
                    text: "󰝟"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.toggleMute();
                            dismissTimer.restart();
                        }
                    }
                }
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
                        root.updateVolume(mouse.x, width);
                    }
                    onPositionChanged: function (mouse) {
                        if (pressed)
                            root.updateVolume(mouse.x, width);
                    }
                }
            }
        }
    }
}
