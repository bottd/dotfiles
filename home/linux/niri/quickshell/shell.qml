import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar

        required property var modelData
        screen: modelData
        property var workspaces: []
        property string windowTitle: ""
        property string networkText: ""
        property string audioText: ""
        property string mullvadText: ""
        property string cellularText: ""
        property string backlightText: ""
        property date now: new Date()
        property var battery: UPower.devices.values.find(device => device.isLaptopBattery)

        anchors.bottom: true
        margins.bottom: 6
        margins.left: 6
        margins.right: 6
        implicitHeight: 32
        exclusiveZone: implicitHeight + 6
        color: "transparent"

        function refreshNiri() {
            if (!workspaceProcess.running)
                workspaceProcess.running = true;
            if (!windowProcess.running)
                windowProcess.running = true;
        }

        function refreshStatus() {
            if (!networkProcess.running)
                networkProcess.running = true;
            if (!audioProcess.running)
                audioProcess.running = true;
            if (!mullvadProcess.running)
                mullvadProcess.running = true;
            if (!cellularProcess.running)
                cellularProcess.running = true;
            if (!backlightProcess.running)
                backlightProcess.running = true;
        }

        function workspaceList() {
            const visible = workspaces.filter(workspace => workspace.output === screen.name);
            if (visible.length > 0)
                return visible.sort((a, b) => a.idx - b.idx);

            return Array.from({
                length: 9
            }, (_, index) => ({
                        idx: index + 1,
                        is_focused: false,
                        is_active: false
                    }));
        }

        function focusWorkspace(index) {
            Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(index)]);
        }

        function run(command) {
            Quickshell.execDetached(command);
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: bar.now = new Date()
        }

        Timer {
            interval: 2000
            running: true
            repeat: true
            onTriggered: bar.refreshNiri()
        }

        Timer {
            interval: 5000
            running: true
            repeat: true
            onTriggered: bar.refreshStatus()
        }

        Process {
            id: workspaceProcess
            command: ["niri", "msg", "-j", "workspaces"]
            running: true
            stdout: StdioCollector {
                id: workspaceOutput
                onStreamFinished: {
                    try {
                        const value = JSON.parse(workspaceOutput.text);
                        bar.workspaces = Array.isArray(value) ? value : (value.workspaces || []);
                    } catch (error) {
                        bar.workspaces = [];
                    }
                }
            }
        }

        Process {
            id: windowProcess
            command: ["niri", "msg", "-j", "focused-window"]
            running: true
            stdout: StdioCollector {
                id: windowOutput
                onStreamFinished: {
                    try {
                        const value = JSON.parse(windowOutput.text);
                        bar.windowTitle = value ? (value.title || "") : "";
                    } catch (error) {
                        bar.windowTitle = "";
                    }
                }
            }
        }

        Process {
            id: networkProcess
            command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null"]
            running: true
            stdout: StdioCollector {
                id: networkOutput
                onStreamFinished: {
                    const line = networkOutput.text.trim().split("\n").find(value => value.includes(":connected:"));
                    if (!line) {
                        bar.networkText = "󰤭 off";
                        return;
                    }

                    const fields = line.split(":");
                    const type = fields[0];
                    const connection = fields.slice(2).join(":");
                    bar.networkText = (type === "wifi" ? "󰤨 " : "󰈀 ") + connection;
                }
            }
        }

        Process {
            id: audioProcess
            command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
            running: true
            stdout: StdioCollector {
                id: audioOutput
                onStreamFinished: {
                    const value = audioOutput.text.trim();
                    const volume = value.match(/([0-9]+(?:\.[0-9]+)?)/);
                    bar.audioText = value.includes("MUTED") ? "󰝟 muted" : ("󰕾 " + (volume ? Math.round(Number(volume[1]) * 100) : 0) + "%");
                }
            }
        }

        Process {
            id: mullvadProcess
            command: ["waybar-mullvad"]
            running: true
            stdout: StdioCollector {
                id: mullvadOutput
                onStreamFinished: {
                    try {
                        const value = JSON.parse(mullvadOutput.text);
                        bar.mullvadText = value.text || "";
                    } catch (error) {
                        bar.mullvadText = mullvadOutput.text.trim();
                    }
                }
            }
        }

        Process {
            id: cellularProcess
            command: ["sh", "-c", "mmcli -m any --output-keyvalue 2>/dev/null"]
            running: true
            stdout: StdioCollector {
                id: cellularOutput
                onStreamFinished: {
                    const value = cellularOutput.text;
                    const state = value.match(/modem\.generic\.state: (.+)/);
                    const signal = value.match(/modem\.generic\.signal-quality\.value: (.+)/);
                    bar.cellularText = state && state[1].trim() === "connected" && signal ? "󰄋 " + signal[1].trim() + "%" : "";
                }
            }
        }

        Process {
            id: backlightProcess
            command: ["sh", "-c", "brightnessctl -m 2>/dev/null"]
            running: true
            stdout: StdioCollector {
                id: backlightOutput
                onStreamFinished: {
                    const value = backlightOutput.text.trim().split(",")[4] || "";
                    bar.backlightText = value ? "󰃟 " + value : "";
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 7
            color: Theme.base00
            border.color: Theme.base02
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                RowLayout {
                    spacing: 4

                    Repeater {
                        model: bar.workspaceList()

                        delegate: Rectangle {
                            required property var modelData

                            implicitWidth: 22
                            implicitHeight: 22
                            radius: 5
                            color: modelData.is_focused ? Theme.base0D : Theme.base02

                            Text {
                                anchors.centerIn: parent
                                text: modelData.idx
                                color: modelData.is_focused ? Theme.base00 : Theme.base05
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: bar.focusWorkspace(modelData.idx)
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: bar.windowTitle
                    elide: Text.ElideRight
                    color: Theme.base05
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                RowLayout {
                    spacing: 8

                    Repeater {
                        model: SystemTray.items

                        delegate: IconImage {
                            required property var modelData

                            implicitWidth: 16
                            implicitHeight: 16
                            source: modelData.icon

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                                onClicked: {
                                    if (mouse.button === Qt.RightButton && modelData.hasMenu)
                                        modelData.display(bar, mouse.x, mouse.y);
                                    else if (mouse.button === Qt.MiddleButton)
                                        modelData.secondaryActivate();
                                    else
                                        modelData.activate();
                                }
                            }
                        }
                    }

                    Text {
                        visible: bar.audioText !== ""
                        text: bar.audioText
                        color: Theme.base05
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize

                        MouseArea {
                            anchors.fill: parent
                            onClicked: bar.run(["pavucontrol"])
                        }
                    }

                    Text {
                        visible: bar.networkText !== ""
                        text: bar.networkText
                        color: Theme.base05
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize

                        MouseArea {
                            anchors.fill: parent
                            onClicked: bar.run(["nm-connection-editor"])
                        }
                    }

                    Text {
                        visible: bar.mullvadText !== ""
                        text: bar.mullvadText
                        color: Theme.base05
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize

                        MouseArea {
                            anchors.fill: parent
                            onClicked: bar.run(["waybar-mullvad", "toggle"])
                        }
                    }

                    Text {
                        visible: bar.cellularText !== ""
                        text: bar.cellularText
                        color: Theme.base05
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize

                        MouseArea {
                            anchors.fill: parent
                            onClicked: bar.run(["nm-connection-editor"])
                        }
                    }

                    Text {
                        visible: bar.backlightText !== ""
                        text: bar.backlightText
                        color: Theme.base05
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize

                        MouseArea {
                            anchors.fill: parent
                            onWheel: {
                                bar.run(["brightnessctl", "set", wheel.angleDelta.y > 0 ? "5%+" : "5%-"]);
                            }
                        }
                    }

                    Text {
                        visible: bar.battery !== undefined && bar.battery !== null
                        text: bar.battery ? ("󰁹 " + Math.round(bar.battery.percentage) + "%") : ""
                        color: Theme.base05
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    Text {
                        text: Qt.formatDateTime(bar.now, "ddd, MMM d at hh:mm")
                        color: Theme.base05
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }
            }
        }
    }
}
