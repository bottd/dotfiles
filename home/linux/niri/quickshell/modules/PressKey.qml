import QtQuick

Rectangle {
    id: root

    required property var theme
    required property string text
    property bool inverted: false

    implicitWidth: Math.max(theme.controlSize, label.implicitWidth + theme.fontSize)
    implicitHeight: theme.controlSize - theme.ruleWidth
    color: inverted ? theme.background : theme.ink
    border.color: inverted ? theme.background : theme.ink
    border.width: theme.ruleWidth

    Text {
        id: label

        anchors.centerIn: parent
        text: root.text.toUpperCase()
        color: root.inverted ? root.theme.ink : root.theme.background
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
        font.bold: true
    }
}
