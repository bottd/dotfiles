import QtQuick

Item {
    id: root

    required property var theme
    default property alias contentData: surface.data
    readonly property int offset: theme.pressOffset * 2
    // The panel prints in head-first through the ordered dither and lifts out
    // tail-first, the same pair niri runs on windows. Owners call printIn()
    // when they appear and pressOut() before hiding, then hide on pressedOut.
    property real progress: 1
    property bool closing: false
    signal pressedOut

    function printIn() {
        liftAnimation.stop();
        closing = false;
        if (!theme.animationsEnabled) {
            progress = 1;
            return;
        }
        progress = 0;
        printAnimation.restart();
    }
    function pressOut() {
        printAnimation.stop();
        if (!theme.animationsEnabled) {
            pressedOut();
            return;
        }
        closing = true;
        progress = 0;
        liftAnimation.restart();
    }

    // Only layered while dithering; at rest the panel renders directly.
    layer.enabled: theme.animationsEnabled && (printAnimation.running || closing)
    layer.smooth: false
    layer.effect: PrintEffect {
        progress: root.progress
        closing: root.closing ? 1 : 0
    }

    NumberAnimation {
        id: printAnimation
        target: root
        property: "progress"
        to: 1
        duration: 240
        easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: liftAnimation
        target: root
        property: "progress"
        to: 1
        duration: 180
        easing.type: Easing.OutQuad
        onFinished: root.pressedOut()
    }

    Rectangle {
        x: root.offset
        y: root.offset
        width: parent.width - root.offset
        height: parent.height - root.offset
        color: root.theme.plate
    }

    Rectangle {
        id: surface

        width: parent.width - root.offset
        height: parent.height - root.offset
        color: root.theme.background
        border.color: root.theme.ink
        border.width: root.theme.ruleWidth * 2

        // Empty space belongs to the panel, not its click-outside backdrop.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onWheel: event => event.accepted = true
        }
    }
}
