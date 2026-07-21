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
    property bool brightnessOpen: false
    property var brightnessScreen: null
    property var workspaces: []
    property string windowTitle: ""
    property var mullvadStatus: ({
            text: "",
            tone: "neutral",
            tooltip: ""
        })
    property var cellularStatus: ({
            text: "",
            tone: "neutral",
            tooltip: ""
        })
    property string backlightText: ""
    property bool backlightAvailable: false
    property real brightnessLevel: 0
    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property bool audioReady: root.audioSink && root.audioSink.ready && root.audioSink.audio
    readonly property real volumeLevel: root.audioReady ? root.audioSink.audio.volume : 0
    readonly property bool volumeMuted: root.audioReady ? root.audioSink.audio.muted : false
    readonly property string audioIcon: root.volumeMuted ? "󰝟" : (root.volumeLevel < 0.01 ? "󰖁" : (root.volumeLevel < 0.34 ? "󰕿" : (root.volumeLevel < 0.67 ? "󰖀" : "󰕾")))
    readonly property var audioStatus: ({
            text: root.audioReady ? root.audioIcon + " " + (root.volumeMuted ? "muted" : Math.round(root.volumeLevel * 100) + "%") : "",
            tone: root.volumeMuted ? "warning" : "neutral",
            tooltip: root.audioReady ? "Volume " + Math.round(root.volumeLevel * 100) + "%" + (root.volumeMuted ? " · muted" : "") : "Audio unavailable"
        })
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
        root.brightnessOpen = false;
        root.volumeScreen = screen;
        root.volumeOpen = !closing;
    }

    function toggleBrightness(screen) {
        if (!root.backlightAvailable)
            return;

        const closing = root.brightnessOpen && root.brightnessScreen === screen;
        root.volumeOpen = false;
        root.brightnessScreen = screen;
        root.brightnessOpen = !closing;
    }

    function setBrightness(level) {
        if (!root.backlightAvailable)
            return;

        root.brightnessLevel = Math.max(0, Math.min(1, level));
        root.backlightText = "󰃟 " + Math.round(root.brightnessLevel * 100) + "%";
        Quickshell.execDetached(["brightnessctl", "--class=backlight", "set", Math.round(root.brightnessLevel * 100) + "%"]);
    }

    function adjustBrightness(increase) {
        if (!root.backlightAvailable)
            return;

        root.brightnessLevel = Math.max(0, Math.min(1, root.brightnessLevel + (increase ? 0.05 : -0.05)));
        root.backlightText = "󰃟 " + Math.round(root.brightnessLevel * 100) + "%";
        Quickshell.execDetached(["brightnessctl", "--class=backlight", "set", increase ? "5%+" : "5%-"]);
        backlightRefreshTimer.restart();
    }

    function connectionTone(state) {
        if (state === "connected")
            return "positive";
        if (["connecting", "reconnecting", "registering", "searching", "enabling", "registered"].includes(state))
            return "warning";
        if (["failed", "error", "daemon-down"].includes(state))
            return "danger";
        return "muted";
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
                    const state = value.class || "daemon-down";
                    root.mullvadStatus = {
                        text: value.text || "",
                        tone: root.connectionTone(state),
                        tooltip: value.tooltip || "Mullvad status unavailable"
                    };
                } catch (error) {
                    root.mullvadStatus = {
                        text: text.trim(),
                        tone: "danger",
                        tooltip: "Mullvad status unavailable"
                    };
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
                const currentState = state ? state[1].trim() : "";
                const signalValue = signal ? signal[1].trim() : "";
                if (currentState === "") {
                    root.cellularStatus = {
                        text: "",
                        tone: "neutral",
                        tooltip: ""
                    };
                    return;
                }

                root.cellularStatus = {
                    text: "󰄋 " + (currentState === "connected" && signalValue ? signalValue + "%" : currentState),
                    tone: root.connectionTone(currentState),
                    tooltip: "Cellular: " + currentState + (signalValue ? " · " + signalValue + "% signal" : "")
                };
            }
        }
    }

    Process {
        id: backlightProcess
        command: ["sh", "-c", "brightnessctl --class=backlight -m 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim().split("\n")[0] || "";
                const fields = line.split(",");
                // Machine output is device,class,current,percentage,max.
                const percentage = fields.length >= 5 ? parseInt(fields[3], 10) : NaN;
                root.backlightAvailable = Number.isFinite(percentage);
                root.backlightText = root.backlightAvailable ? "󰃟 " + percentage + "%" : "";
                root.brightnessLevel = root.backlightAvailable ? percentage / 100 : 0;
                if (!root.backlightAvailable)
                    root.brightnessOpen = false;
            }
        }
    }

    Timer {
        id: backlightRefreshTimer

        interval: 250
        onTriggered: backlightProcess.running = true
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

    Modules.BrightnessPopup {
        screen: root.brightnessScreen || Quickshell.screens[0]
        theme: shellTheme
        visible: root.brightnessOpen
        level: root.brightnessLevel
        onSetBrightness: level => root.setBrightness(level)
        onDismissed: root.brightnessOpen = false
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
            margins.bottom: keyOverlay.screen === modelData ? keyOverlay.revealedHeight : 0
            implicitHeight: 32
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: shellTheme.background
                border.color: shellTheme.border
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
                        color: shellTheme.textPrimary
                        font.family: shellTheme.fontFamily
                        font.pixelSize: shellTheme.fontSize
                    }

                    Modules.SystemTray {
                        parentWindow: bar
                        theme: shellTheme
                    }

                    Modules.StatusModules {
                        audioStatus: root.audioStatus
                        mullvadStatus: root.mullvadStatus
                        cellularStatus: root.cellularStatus
                        backlightText: root.backlightText
                        battery: root.battery
                        now: clock.date
                        theme: shellTheme
                        onAudioClicked: root.toggleVolume(bar.screen)
                        onMullvadClicked: Quickshell.execDetached(["waybar-mullvad", "toggle"])
                        onCellularClicked: Quickshell.execDetached(["nm-connection-editor"])
                        onBacklightClicked: root.toggleBrightness(bar.screen)
                        onBacklightWheel: increase => root.adjustBrightness(increase)
                    }
                }
            }
        }
    }
}
