import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var theme
    required property real value
    property string accessibleName: "Level"
    signal moved(real value)

    readonly property real clampedValue: Math.max(0, Math.min(1, root.value))
    readonly property bool dragging: sliderMouse.pressed

    implicitHeight: root.theme.controlSize
    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.name: root.accessibleName
    Accessible.description: Math.round(root.clampedValue * 100) + "%"

    function moveTo(x) {
        root.moved(Math.max(0, Math.min(1, x / root.width)));
    }

    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            root.moved(Math.max(0, root.value - 0.05));
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            root.moved(Math.min(Math.max(1, root.value), root.value + 0.05));
            event.accepted = true;
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root.theme.controlSize
        radius: root.theme.radius
        color: "transparent"
        border.color: root.activeFocus ? root.theme.ink : "transparent"
        border.width: root.theme.ruleWidth
    }

    Rectangle {
        id: track

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root.theme.fontSize
        radius: root.theme.radius
        clip: true
        color: root.theme.background
        border.color: root.theme.ink
        border.width: root.theme.ruleWidth

        Rectangle {
            width: parent.width * root.clampedValue
            y: root.theme.ruleWidth
            height: parent.height - root.theme.ruleWidth * 2
            radius: parent.radius
            color: root.theme.ink
        }
    }

    Rectangle {
        width: root.theme.fontSize * 1.5
        height: root.theme.fontSize * 1.5
        x: Math.max(0, Math.min(root.width - width, root.width * root.clampedValue - width / 2))
        anchors.verticalCenter: parent.verticalCenter
        radius: root.theme.radius
        color: sliderMouse.pressed ? root.theme.ink : root.theme.background
        border.color: root.theme.ink
        border.width: root.theme.ruleWidth * 2
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
