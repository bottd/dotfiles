import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var theme
    required property real value
    property string accessibleName: "Level"
    signal moved(real value)

    readonly property real clampedValue: Math.max(0, Math.min(1, root.value))

    implicitHeight: 28
    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.name: root.accessibleName
    Accessible.description: Math.round(root.clampedValue * 100) + "%"

    function moveTo(x) {
        root.moved(Math.max(0, Math.min(1, x / root.width)));
    }

    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            root.moved(Math.max(0, root.clampedValue - 0.05));
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            root.moved(Math.min(1, root.clampedValue + 0.05));
            event.accepted = true;
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 14
        radius: 7
        color: "transparent"
        border.color: root.activeFocus ? root.theme.focusRing : "transparent"
        border.width: 1
    }

    Rectangle {
        id: track

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 8
        radius: 4
        clip: true
        color: sliderMouse.containsMouse ? root.theme.surfacePressed : root.theme.surfaceSelected

        Rectangle {
            width: parent.width * root.clampedValue
            height: parent.height
            radius: parent.radius
            color: root.theme.accent
        }
    }

    Rectangle {
        width: 12
        height: 12
        x: Math.max(0, Math.min(root.width - width, root.width * root.clampedValue - width / 2))
        anchors.verticalCenter: parent.verticalCenter
        radius: 6
        color: root.theme.accent
        border.color: root.theme.background
        border.width: 1
        opacity: sliderMouse.pressed ? 0.7 : 1
    }

    MouseArea {
        id: sliderMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: function (mouse) {
            root.forceActiveFocus();
            root.moveTo(mouse.x);
        }
        onPositionChanged: function (mouse) {
            if (pressed)
                root.moveTo(mouse.x);
        }
    }

    ToolTip.visible: sliderMouse.containsMouse
    ToolTip.delay: 500
    ToolTip.text: root.accessibleName + " " + Math.round(root.clampedValue * 100) + "%"
}
