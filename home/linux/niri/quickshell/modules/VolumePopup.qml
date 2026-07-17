import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var screen
    required property var theme
    required property bool open
    required property real level
    required property string label
    required property bool muted
    signal setVolume(real level)
    signal toggleMute
    signal dismissed

    screen: root.screen
    anchors.bottom: true
    anchors.right: true
    margins.bottom: 48
    margins.right: 120
    implicitWidth: 240
    implicitHeight: 96
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: root.open
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "drake-volume-popup"

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

                Text {
                    Layout.fillWidth: true
                    text: root.muted ? "󰝟 muted" : root.label
                    color: root.theme.base05
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                }

                Text {
                    text: "󰝟"
                    color: root.theme.base05
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.toggleMute()
                    }
                }
            }

            Rectangle {
                id: track

                Layout.fillWidth: true
                height: 8
                radius: 4
                clip: true
                color: root.theme.base02

                Rectangle {
                    width: track.width * Math.max(0, Math.min(1, root.level))
                    height: parent.height
                    radius: parent.radius
                    color: root.theme.base0D
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: function (mouse) {
                        root.setVolume(Math.max(0, Math.min(1, mouse.x / width)));
                    }
                    onPositionChanged: function (mouse) {
                        if (pressed)
                            root.setVolume(Math.max(0, Math.min(1, mouse.x / width)));
                    }
                }
            }
        }
    }
}
