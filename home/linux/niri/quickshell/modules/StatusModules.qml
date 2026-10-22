import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

RowLayout {
    id: root

    required property var audioStatus
    required property var vpnStatus
    required property var networkStatus
    required property string backlightText
    required property var battery
    required property date now
    required property var theme
    signal audioClicked
    signal vpnClicked
    signal networkClicked
    signal backlightClicked
    signal backlightWheel(bool increase)

    spacing: Math.round(theme.fontSize / 3) // 4

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

    // A slug set straight on the bar's paper. Hover reverses it out of ink
    // over an off-register plate; a press drops the face onto that plate.
    // Tone rides as a leading shape (circle positive, diamond warning, square
    // danger) so it reads on grayscale eink; danger also keylines the slug.
    component StatusButton: Item {
        id: control

        property string text: ""
        property string description: text
        property bool wheelEnabled: false
        property bool interactive: true
        property real wheelRemainder: 0
        property string tone: "neutral"
        readonly property bool toned: tone !== "neutral" && tone !== "muted"
        readonly property bool inverted: interactive && buttonMouse.containsMouse
        readonly property int marker: Math.max(5, Math.round(root.theme.fontSize / 2.4)) // 5
        signal activated
        signal scrolled(bool increase)

        implicitWidth: face.implicitWidth + root.theme.plateOffset
        implicitHeight: root.theme.controlSize
        Accessible.role: control.interactive ? Accessible.Button : Accessible.StaticText
        Accessible.name: control.description

        Rectangle {
            visible: control.inverted || control.tone === "danger"
            x: root.theme.plateOffset
            y: root.theme.plateOffset
            width: face.width
            height: face.height
            color: control.tone === "danger" ? root.theme.danger : root.theme.plate
        }

        Rectangle {
            id: face

            readonly property bool down: control.interactive && buttonMouse.pressed

            x: down ? root.theme.plateOffset : 0
            y: down ? root.theme.plateOffset : 0
            implicitWidth: content.implicitWidth + root.theme.fontSize
            width: implicitWidth
            height: parent.height - root.theme.plateOffset
            radius: root.theme.radius
            color: control.inverted ? root.theme.ink : root.theme.background
            border.color: control.tone === "danger" ? root.theme.danger : root.theme.ink
            border.width: control.inverted || control.tone === "danger" ? root.theme.ruleWidth : 0

            Row {
                id: content

                anchors.centerIn: parent
                spacing: Math.round(root.theme.fontSize / 2.4) // 5

                Rectangle {
                    visible: control.toned
                    anchors.verticalCenter: parent.verticalCenter
                    width: control.marker
                    height: control.marker
                    radius: control.tone === "positive" ? width / 2 : 0
                    rotation: control.tone === "warning" ? 45 : 0
                    color: control.inverted ? root.theme.background : root.toneColor(control.tone)
                }

                Text {
                    text: control.text
                    textFormat: Text.PlainText
                    color: control.inverted ? root.theme.background : (control.tone === "muted" ? root.theme.textMuted : root.theme.textPrimary)
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                }
            }
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: control.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (control.interactive)
                    control.activated();
                else
                    tip.pinned = !tip.pinned;
            }
            onPressAndHold: tip.pinned = true
            onWheel: function (wheel) {
                if (!control.wheelEnabled) {
                    wheel.accepted = false;
                    return;
                }
                if (wheel.phase === Qt.ScrollBegin)
                    control.wheelRemainder = 0;
                control.wheelRemainder += wheel.angleDelta.y;
                while (Math.abs(control.wheelRemainder) >= 120) {
                    const increase = control.wheelRemainder > 0;
                    control.scrolled(increase);
                    control.wheelRemainder += increase ? -120 : 120;
                }
                if (wheel.phase === Qt.ScrollEnd)
                    control.wheelRemainder = 0;
            }
        }

        BarTooltip {
            id: tip

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
        visible: root.vpnStatus.text !== ""
        text: root.vpnStatus.text || ""
        description: root.vpnStatus.tooltip || "Toggle VPN exit node"
        tone: root.vpnStatus.tone || "neutral"
        onActivated: root.vpnClicked()
    }

    StatusButton {
        visible: root.networkStatus.text !== ""
        text: root.networkStatus.text || ""
        description: root.networkStatus.tooltip || "Network"
        tone: root.networkStatus.tone || "neutral"
        onActivated: root.networkClicked()
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

    // Date set muted, time set bold: the bar's one typographic moment.
    Row {
        Layout.leftMargin: Math.round(root.theme.fontSize / 2) // 6
        spacing: Math.round(root.theme.fontSize / 2) // 6
        Accessible.role: Accessible.StaticText
        Accessible.name: Qt.formatDateTime(root.now, "dddd, MMMM d, h:mm AP")

        StatusLabel {
            text: Qt.formatDateTime(root.now, "ddd MMM d")
            color: root.theme.textMuted
        }
        StatusLabel {
            text: Qt.formatTime(root.now, "h:mm AP")
            font.bold: true
        }
    }
}
