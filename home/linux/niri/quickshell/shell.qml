//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "./modules" as Modules

ShellRoot {
    id: root

    property bool launcherOpen: false
    property bool keyOverlayOpen: false
    property bool volumeOpen: false
    property bool volumeMuted: false
    property real volumeLevel: 0
    property var volumeScreen: null

    Theme {
        id: shellTheme
    }

    function setVolume(level) {
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", String(level)]);
        root.volumeLevel = level;
        root.refreshAudio();
    }

    function toggleMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
        root.volumeMuted = !root.volumeMuted;
        root.refreshAudio();
    }

    function toggleVolume(screen) {
        if (root.volumeOpen && root.volumeScreen === screen) {
            root.volumeOpen = false;
            return;
        }

        root.volumeScreen = screen;
        root.volumeOpen = true;
    }

    signal refreshAudio

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.launcherOpen = !root.launcherOpen;
        }
    }

    IpcHandler {
        target: "key-overlay"

        function toggle(): void {
            root.keyOverlayOpen = !root.keyOverlayOpen;
        }
    }

    Modules.VolumePopup {
        screen: root.volumeScreen ? root.volumeScreen : Quickshell.screens[0]
        theme: shellTheme
        open: root.volumeOpen
        level: root.volumeLevel
        label: "󰕾 " + Math.round(root.volumeLevel * 100) + "%"
        muted: root.volumeMuted
        onSetVolume: level => root.setVolume(level)
        onToggleMute: root.toggleMute()
        onDismissed: root.volumeOpen = false
    }

    Modules.Launcher {
        screen: Quickshell.screens[0]
        theme: shellTheme
        open: root.launcherOpen
        onDismissed: root.launcherOpen = false
    }

    Modules.KeyOverlay {
        screen: Quickshell.screens[0]
        theme: shellTheme
        open: root.keyOverlayOpen
        onDismissed: root.keyOverlayOpen = false
    }

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
                        root.volumeLevel = volume ? Math.max(0, Math.min(1, Number(volume[1]))) : 0;
                        root.volumeMuted = value.includes("MUTED");
                        bar.audioText = root.volumeMuted ? "󰝟 muted" : ("󰕾 " + Math.round(root.volumeLevel * 100) + "%");
                    }
                }
            }

            Connections {
                target: root
                function onRefreshAudio() {
                    audioProcess.running = false;
                    audioProcess.running = true;
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
                        onAudioClicked: root.toggleVolume(bar.screen)
                        onMullvadClicked: bar.run(["waybar-mullvad", "toggle"])
                        onCellularClicked: bar.run(["nm-connection-editor"])
                        onBacklightWheel: increase => bar.run(["brightnessctl", "set", increase ? "5%+" : "5%-"])
                    }
                }
            }
        }
    }
}
