import QtQuick
import QtQuick.Controls
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
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "drake-brightness-popup"

    onScreenChanged: {
        if (root.visible)
            dismissTimer.restart();
    }

    function updateBrightness(level) {
        root.setBrightness(level);
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
        color: root.theme.background
        border.color: root.theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "󰃟 " + Math.round(root.level * 100) + "%"
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
            }

            LevelSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                theme: root.theme
                value: root.level
                accessibleName: "Brightness"
                onMoved: value => root.updateBrightness(value)
            }
        }
    }
}
