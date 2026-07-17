import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "./modules" as Modules

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar

        required property var modelData
        screen: modelData
        Theme {
            id: theme
        }
        property var workspaces: []
        property string windowTitle: ""
        property string audioText: ""
        property string mullvadText: ""
        property string cellularText: ""
        property string backlightText: ""
        property date now: new Date()
        property var battery: UPower.devices.values.find(device => device.isLaptopBattery)

        anchors.bottom: true
        anchors.left: true
        anchors.right: true
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
            if (!audioProcess.running)
                audioProcess.running = true;
            if (!mullvadProcess.running)
                mullvadProcess.running = true;
            if (!cellularProcess.running)
                cellularProcess.running = true;
            if (!backlightProcess.running)
                backlightProcess.running = true;
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
            color: theme.base00
            border.color: theme.base02
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Modules.WorkspaceList {
                    workspaces: bar.workspaces
                    screenName: bar.screen.name
                    theme: theme
                    onFocusWorkspace: index => bar.focusWorkspace(index)
                }

                Text {
                    Layout.fillWidth: true
                    text: bar.windowTitle
                    elide: Text.ElideRight
                    color: theme.base05
                    font.family: theme.fontFamily
                    font.pixelSize: theme.fontSize
                }

                Modules.SystemTray {
                    parentWindow: bar
                    theme: theme
                }

                Modules.StatusModules {
                    audioText: bar.audioText
                    mullvadText: bar.mullvadText
                    cellularText: bar.cellularText
                    backlightText: bar.backlightText
                    battery: bar.battery
                    now: bar.now
                    theme: theme
                    onAudioClicked: bar.run(["pavucontrol"])
                    onMullvadClicked: bar.run(["waybar-mullvad", "toggle"])
                    onCellularClicked: bar.run(["nm-connection-editor"])
                    onBacklightWheel: increase => bar.run(["brightnessctl", "set", increase ? "5%+" : "5%-"])
                }
            }
        }
    }
}
