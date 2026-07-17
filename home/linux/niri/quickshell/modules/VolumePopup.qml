import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: root

    required property var parentWindow
    required property var theme
    required property bool open
    required property real level
    required property string label
    signal setVolume(real level)
    signal toggleMute
    signal dismissed

    anchor.window: root.parentWindow
    anchor.rect.x: root.parentWindow.width - width - 120
    anchor.rect.y: -height - 10
    width: 240
    height: 96
    visible: root.open
    grabFocus: true

    onVisibleChanged: {
        if (!visible && root.open)
            root.dismissed();
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

                Text {
                    Layout.fillWidth: true
                    text: root.label
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
                color: root.theme.base02

                Rectangle {
                    width: track.width * root.level
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
