import QtQuick
import QtQuick.Controls

// The stock bar is a rounded pill that fades in and out. This one is a square
// ink slug in a ruled channel, and it is simply there or not.
ScrollBar {
    id: root

    required property var theme

    policy: ScrollBar.AsNeeded
    padding: 0
    minimumSize: 0.1
    contentItem: Rectangle {
        implicitWidth: root.theme.ruleWidth * 2
        implicitHeight: root.theme.ruleWidth * 2
        color: root.theme.ink
        visible: root.size < 1
    }
    background: Rectangle {
        implicitWidth: root.theme.ruleWidth * 2
        color: root.theme.surfaceHover
        visible: root.size < 1
    }
}
