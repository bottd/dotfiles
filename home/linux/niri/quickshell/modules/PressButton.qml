import QtQuick

// The input rectangle stays still while the printed face depresses into its plate.
Item {
    id: root

    required property var theme
    property bool selected: false
    property bool dangerous: false
    readonly property bool hovered: mouse.containsMouse
    readonly property bool inverted: enabled && (selected || hovered)
    // Keyboard focus keeps the face on paper but doubles its rule and prints
    // the plate, so Tab focus never reads as the pointer's hover.
    readonly property bool focused: activeFocus && !inverted
    readonly property color rule: !enabled ? theme.textMuted : (dangerous ? theme.danger : theme.ink)
    readonly property color foreground: inverted ? theme.background : (enabled ? theme.ink : theme.textMuted)
    // Keyboard activation stamps the face down briefly, like a click does.
    property bool stamped: false
    readonly property bool down: mouse.pressed || stamped
    default property alias contentData: face.data
    signal clicked

    implicitHeight: theme.rowHeight + theme.pressOffset
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.onPressAction: {
        if (root.enabled)
            root.clicked();
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.stamped = true;
            stampTimer.restart();
            root.clicked();
            event.accepted = true;
        }
    }

    Rectangle {
        x: root.theme.pressOffset
        y: root.theme.pressOffset
        width: face.width
        height: face.height
        color: !root.enabled ? root.theme.surfaceHover : (root.dangerous ? root.theme.danger : (root.inverted || root.focused ? root.theme.plate : root.theme.ink))
    }

    Rectangle {
        id: face

        x: root.down ? root.theme.pressOffset : 0
        y: root.down ? root.theme.pressOffset : 0
        width: root.width - root.theme.pressOffset
        height: root.height - root.theme.pressOffset
        color: root.inverted ? root.theme.ink : root.theme.background
        border.color: root.rule
        border.width: root.focused ? root.theme.ruleWidth * 2 : root.theme.ruleWidth
    }

    Timer {
        id: stampTimer
        interval: 90
        onTriggered: root.stamped = false
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onDoubleClicked: mouse => mouse.accepted = true
    }
}
