//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "./modules" as Modules

ShellRoot {
    id: root

    property bool drawerOpen: false
    property string drawerMode: "commands"
    property string pendingDrawerMode: ""
    property var drawerScreen: null
    property bool volumeOpen: false
    property var volumeScreen: null
    property var workspaces: []
    property string windowTitle: ""
    property string mullvadText: ""
    property string cellularText: ""
    property string backlightText: ""
    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property bool audioReady: root.audioSink && root.audioSink.ready && root.audioSink.audio
    readonly property real volumeLevel: root.audioReady ? root.audioSink.audio.volume : 0
    readonly property bool volumeMuted: root.audioReady ? root.audioSink.audio.muted : false
    readonly property string audioText: root.audioReady ? (root.volumeMuted ? "󰝟 muted" : ("󰕾 " + Math.round(root.volumeLevel * 100) + "%")) : ""
    readonly property var battery: UPower.devices.values.find(device => device.isLaptopBattery)

    Theme {
        id: shellTheme
    }

    PwObjectTracker {
        objects: root.audioSink ? [root.audioSink] : []
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            workspaceProcess.running = true;
            windowProcess.running = true;
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            mullvadProcess.running = true;
            cellularProcess.running = true;
            backlightProcess.running = true;
        }
    }

    function toggleVolume(screen) {
        const closing = root.volumeOpen && root.volumeScreen === screen;
        root.volumeScreen = screen;
        root.volumeOpen = !closing;
    }

    function toggleDrawer(mode) {
        if (root.drawerOpen) {
            root.drawerOpen = root.drawerMode !== mode;
            root.drawerMode = mode;
            return;
        }

        if (focusedOutputProcess.running) {
            root.pendingDrawerMode = root.pendingDrawerMode === mode ? "" : mode;
            return;
        }

        root.pendingDrawerMode = mode;
        focusedOutputProcess.running = true;
    }

    Process {
        id: workspaceProcess
        command: ["niri", "msg", "-j", "workspaces"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    const value = Array.isArray(parsed) ? parsed : parsed.workspaces;
                    if (Array.isArray(value))
                        root.workspaces = value;
                } catch (error) {}
            }
        }
    }

    Process {
        id: windowProcess
        command: ["niri", "msg", "-j", "focused-window"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const value = JSON.parse(text);
                    root.windowTitle = value ? (value.title || "") : "";
                } catch (error) {}
            }
        }
    }

    Process {
        id: mullvadProcess
        command: ["waybar-mullvad"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const value = JSON.parse(text);
                    root.mullvadText = value.text || "";
                } catch (error) {
                    root.mullvadText = text.trim();
                }
            }
        }
    }

    Process {
        id: cellularProcess
        command: ["sh", "-c", "mmcli -m any --output-keyvalue 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text;
                const state = value.match(/modem\.generic\.state: (.+)/);
                const signal = value.match(/modem\.generic\.signal-quality\.value: (.+)/);
                root.cellularText = state && state[1].trim() === "connected" && signal ? "󰄋 " + signal[1].trim() + "%" : "";
            }
        }
    }

    Process {
        id: backlightProcess
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim().split(",")[4] || "";
                root.backlightText = value ? "󰃟 " + value : "";
            }
        }
    }

    Process {
        id: focusedOutputProcess

        command: ["niri", "msg", "-j", "focused-output"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.pendingDrawerMode === "")
                    return;

                let outputName = "";
                try {
                    outputName = JSON.parse(text).name || "";
                } catch (error) {}

                root.drawerScreen = Quickshell.screens.find(screen => screen.name === outputName) || Quickshell.screens[0];
                root.drawerMode = root.pendingDrawerMode;
                root.pendingDrawerMode = "";
                root.drawerOpen = true;
            }
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggleDrawer("launcher");
        }
    }

    IpcHandler {
        target: "key-overlay"

        function toggle(): void {
            root.toggleDrawer("commands");
        }
    }

    Modules.VolumePopup {
        screen: root.volumeScreen || Quickshell.screens[0]
        theme: shellTheme
        visible: root.volumeOpen
        level: root.volumeLevel
        muted: root.volumeMuted
        onSetVolume: level => {
            if (root.audioReady)
                root.audioSink.audio.volume = Math.max(0, Math.min(1, level));
        }
        onToggleMute: {
            if (root.audioReady)
                root.audioSink.audio.muted = !root.audioSink.audio.muted;
        }
        onDismissed: root.volumeOpen = false
    }

    Modules.KeyOverlay {
        id: keyOverlay

        screen: root.drawerScreen || Quickshell.screens[0]
        theme: shellTheme
        open: root.drawerOpen
        mode: root.drawerMode
        now: clock.date
        onDismissed: root.drawerOpen = false
        onModeRequested: mode => root.drawerMode = mode
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 1
            exclusiveZone: 32
            color: "transparent"
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            screen: modelData

            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            margins.bottom: keyOverlay.presented && keyOverlay.screen === modelData ? keyOverlay.implicitHeight : 0
            implicitHeight: 32
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: shellTheme.base00
                border.color: shellTheme.base02
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Modules.WorkspaceList {
                        workspaces: root.workspaces
                        screenName: bar.screen.name
                        theme: shellTheme
                        onFocusWorkspace: index => Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(index)])
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.windowTitle
                        elide: Text.ElideRight
                        color: shellTheme.base05
                        font.family: shellTheme.fontFamily
                        font.pixelSize: shellTheme.fontSize
                    }

                    Modules.SystemTray {
                        parentWindow: bar
                    }

                    Modules.StatusModules {
                        audioText: root.audioText
                        mullvadText: root.mullvadText
                        cellularText: root.cellularText
                        backlightText: root.backlightText
                        battery: root.battery
                        now: clock.date
                        theme: shellTheme
                        onAudioClicked: root.toggleVolume(bar.screen)
                        onMullvadClicked: Quickshell.execDetached(["waybar-mullvad", "toggle"])
                        onCellularClicked: Quickshell.execDetached(["nm-connection-editor"])
                        onBacklightWheel: increase => Quickshell.execDetached(["brightnessctl", "set", increase ? "5%+" : "5%-"])
                    }
                }
            }
        }
    }
}
