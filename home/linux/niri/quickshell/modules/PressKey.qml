import QtQuick

Rectangle {
    id: root

    required property var theme
    required property string text
    property bool inverted: false
    // Caption-sized, for the legend under a sheet rather than a row's own key.
    property bool compact: false

    implicitWidth: compact ? label.implicitWidth + theme.captionSize : Math.max(theme.controlSize, label.implicitWidth + theme.fontSize)
    implicitHeight: compact ? Math.round(theme.captionSize * 1.7) : theme.controlSize - theme.ruleWidth // 17 : 26
    color: inverted ? theme.background : theme.ink
    border.color: inverted ? theme.background : theme.ink
    border.width: theme.ruleWidth

    Text {
        id: label

        anchors.centerIn: parent
        text: root.text.toUpperCase()
        color: root.inverted ? root.theme.ink : root.theme.background
        font.family: root.theme.fontFamily
        font.pixelSize: root.compact ? root.theme.captionSize : root.theme.fontSize
        font.bold: true
    }
}
