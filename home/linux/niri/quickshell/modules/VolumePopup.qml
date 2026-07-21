import QtQuick
import QtQuick.Controls
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
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "drake-volume-popup"

    onScreenChanged: {
        if (root.visible)
            dismissTimer.restart();
    }

    function updateVolume(level) {
        root.setVolume(level);
        dismissTimer.restart();
    }

    component PopupText: Text {
        color: root.theme.textPrimary
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
        color: root.theme.background
        border.color: root.theme.border
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

                Rectangle {
                    id: muteButton

                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 4
                    color: muteMouse.pressed ? root.theme.surfacePressed : (muteMouse.containsMouse ? root.theme.surfaceHover : root.theme.surface)
                    border.color: muteButton.activeFocus || muteMouse.containsMouse ? root.theme.focusRing : root.theme.border
                    border.width: 1
                    activeFocusOnTab: true
                    Accessible.role: Accessible.Button
                    Accessible.name: root.muted ? "Unmute" : "Mute"

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            root.toggleMute();
                            dismissTimer.restart();
                            event.accepted = true;
                        }
                    }

                    PopupText {
                        anchors.centerIn: parent
                        text: "󰝟"
                    }

                    MouseArea {
                        id: muteMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            muteButton.forceActiveFocus();
                            root.toggleMute();
                            dismissTimer.restart();
                        }
                    }

                    ToolTip.visible: muteMouse.containsMouse
                    ToolTip.delay: 500
                    ToolTip.text: root.muted ? "Unmute" : "Mute"
                }
            }

            LevelSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                theme: root.theme
                value: root.level
                accessibleName: "Volume"
                onMoved: value => root.updateVolume(value)
            }
        }
    }
}
