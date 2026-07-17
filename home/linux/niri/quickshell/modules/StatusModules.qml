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

    component StatusText: Text {
        color: root.theme.base05
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
    }

    StatusText {
        visible: root.audioText !== ""
        text: root.audioText

        MouseArea {
            anchors.fill: parent
            onClicked: root.audioClicked()
        }
    }

    StatusText {
        visible: root.mullvadText !== ""
        text: root.mullvadText

        MouseArea {
            anchors.fill: parent
            onClicked: root.mullvadClicked()
        }
    }

    StatusText {
        visible: root.cellularText !== ""
        text: root.cellularText

        MouseArea {
            anchors.fill: parent
            onClicked: root.cellularClicked()
        }
    }

    StatusText {
        visible: root.backlightText !== ""
        text: root.backlightText

        MouseArea {
            anchors.fill: parent
            onWheel: root.backlightWheel(wheel.angleDelta.y > 0)
        }
    }

    StatusText {
        visible: !!root.battery
        text: root.battery ? ("󰁹 " + Math.round(root.battery.percentage * 100) + "%") : ""
    }

    StatusText {
        text: Qt.formatDateTime(root.now, "ddd, MMM d at hh:mm")
    }
}
