import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

RowLayout {
    id: root

    required property var audioStatus
    required property var mullvadStatus
    required property var cellularStatus
    required property string backlightText
    required property var battery
    required property date now
    required property var theme
    signal audioClicked
    signal mullvadClicked
    signal cellularClicked
    signal backlightClicked
    signal backlightWheel(bool increase)

    spacing: 8

    function toneColor(tone) {
        if (tone === "positive")
            return root.theme.statusPositive;
        if (tone === "warning")
            return root.theme.statusWarning;
        if (tone === "danger")
            return root.theme.danger;
        if (tone === "muted")
            return root.theme.textMuted;
        return root.theme.textPrimary;
    }

    function batteryPercent() {
        return root.battery ? Math.round(root.battery.percentage * 100) : 0;
    }

    function batteryIcon() {
        if (!root.battery)
            return "";
        if (root.battery.state === UPowerDeviceState.Charging || root.battery.state === UPowerDeviceState.PendingCharge)
            return "󰂄";
        if (root.battery.state === UPowerDeviceState.FullyCharged)
            return "󰁹";
        if (root.batteryPercent() <= 5)
            return "󰂎";

        const icons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
        return icons[Math.min(9, Math.max(0, Math.ceil(root.batteryPercent() / 10) - 1))];
    }

    function batteryTone() {
        if (!root.battery)
            return "neutral";
        if (root.battery.state === UPowerDeviceState.Charging || root.battery.state === UPowerDeviceState.PendingCharge)
            return "positive";
        if (root.batteryPercent() <= 15)
            return "danger";
        if (root.batteryPercent() <= 30)
            return "warning";
        return "neutral";
    }

    function formatDuration(seconds) {
        if (seconds <= 0)
            return "";
        const totalMinutes = Math.max(1, Math.round(seconds / 60));
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;
        return (hours > 0 ? hours + "h " : "") + minutes + "m";
    }

    function batteryDescription() {
        if (!root.battery)
            return "";

        let state = "Battery";
        let remaining = root.battery.timeToEmpty;
        if (root.battery.state === UPowerDeviceState.Charging || root.battery.state === UPowerDeviceState.PendingCharge) {
            state = "Charging";
            remaining = root.battery.timeToFull;
        } else if (root.battery.state === UPowerDeviceState.FullyCharged) {
            state = "Fully charged";
        } else if (root.battery.state === UPowerDeviceState.Discharging) {
            state = "Discharging";
        }

        const duration = root.formatDuration(remaining);
        return state + " · " + root.batteryPercent() + "%" + (duration ? " · " + duration + " remaining" : "");
    }

    component StatusLabel: Text {
        color: root.theme.textPrimary
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
    }

    component StatusButton: Rectangle {
        id: control

        property string text: ""
        property string description: text
        property bool wheelEnabled: false
        property bool interactive: true
        property string tone: "neutral"
        signal activated
        signal scrolled(bool increase)

        implicitWidth: label.implicitWidth + 12
        implicitHeight: 28
        radius: 4
        color: buttonMouse.pressed ? root.theme.surfacePressed : (buttonMouse.containsMouse ? root.theme.surfaceHover : root.theme.surface)
        border.color: buttonMouse.containsMouse ? root.theme.focusRing : (control.tone === "neutral" || control.tone === "muted" ? root.theme.border : root.toneColor(control.tone))
        border.width: 1
        Accessible.role: control.interactive ? Accessible.Button : Accessible.StaticText
        Accessible.name: control.description

        Text {
            id: label

            anchors.centerIn: parent
            text: control.text
            color: control.tone === "muted" ? root.theme.textMuted : root.theme.textPrimary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSize
        }

        Rectangle {
            visible: control.tone !== "neutral" && control.tone !== "muted"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 3
            width: 5
            height: 5
            radius: 3
            color: root.toneColor(control.tone)
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: control.interactive ? Qt.LeftButton : Qt.NoButton
            cursorShape: control.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (control.interactive)
                    control.activated();
            }
            onWheel: function (wheel) {
                if (control.wheelEnabled)
                    control.scrolled(wheel.angleDelta.y > 0);
                else
                    wheel.accepted = false;
            }
        }

        BarTooltip {
            anchorItem: control
            theme: root.theme
            text: control.description
            show: buttonMouse.containsMouse
        }
    }

    StatusButton {
        visible: root.audioStatus.text !== ""
        text: root.audioStatus.text || ""
        description: root.audioStatus.tooltip || "Volume"
        tone: root.audioStatus.tone || "neutral"
        onActivated: root.audioClicked()
    }

    StatusButton {
        visible: root.mullvadStatus.text !== ""
        text: root.mullvadStatus.text || ""
        description: root.mullvadStatus.tooltip || "Toggle Mullvad VPN"
        tone: root.mullvadStatus.tone || "neutral"
        onActivated: root.mullvadClicked()
    }

    StatusButton {
        visible: root.cellularStatus.text !== ""
        text: root.cellularStatus.text || ""
        description: root.cellularStatus.tooltip || "Open cellular settings"
        tone: root.cellularStatus.tone || "neutral"
        onActivated: root.cellularClicked()
    }

    StatusButton {
        visible: root.backlightText !== ""
        text: root.backlightText
        description: "Display brightness"
        wheelEnabled: true
        onActivated: root.backlightClicked()
        onScrolled: increase => root.backlightWheel(increase)
    }

    StatusButton {
        visible: !!root.battery
        text: root.battery ? root.batteryIcon() + " " + root.batteryPercent() + "%" : ""
        description: root.batteryDescription()
        interactive: false
        tone: root.batteryTone()
    }

    StatusLabel {
        text: Qt.formatDateTime(root.now, "ddd, MMM d at hh:mm")
    }
}
