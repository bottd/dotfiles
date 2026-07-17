import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property string audioText
    required property string mullvadText
    required property string cellularText
    required property string backlightText
    required property var battery
    required property date now
    required property var theme
    signal audioClicked
    signal mullvadClicked
    signal cellularClicked
    signal backlightWheel(bool increase)

    spacing: 8

    Text {
        visible: root.audioText !== ""
        text: root.audioText
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize

        MouseArea {
            anchors.fill: parent
            onClicked: root.audioClicked()
        }
    }

    Text {
        visible: root.mullvadText !== ""
        text: root.mullvadText
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize

        MouseArea {
            anchors.fill: parent
            onClicked: root.mullvadClicked()
        }
    }

    Text {
        visible: root.cellularText !== ""
        text: root.cellularText
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize

        MouseArea {
            anchors.fill: parent
            onClicked: root.cellularClicked()
        }
    }

    Text {
        visible: root.backlightText !== ""
        text: root.backlightText
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize

        MouseArea {
            anchors.fill: parent
            onWheel: root.backlightWheel(wheel.angleDelta.y > 0)
        }
    }

    Text {
        visible: root.battery !== undefined && root.battery !== null
        text: root.battery ? ("󰁹 " + Math.round(root.battery.percentage) + "%") : ""
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
    }

    Text {
        text: Qt.formatDateTime(root.now, "ddd, MMM d at hh:mm")
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
    }
}
