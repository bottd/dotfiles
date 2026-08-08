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
    property var drawerScreen: null
    property bool volumeOpen: false
    property var volumeScreen: null
    property bool brightnessOpen: false
    property var brightnessScreen: null
    property var workspaces: []
    // id -> title, mutated in place. WindowFocusChanged carries only an id, so a
    // lookup table is needed; but nothing outside this file reads the window
    // objects, and reassigning an N-element array on every title change (a
    // terminal spinner emits several a second) invalidated every binding on it.
    property var windowTitles: ({})
    property int focusedWindowId: -1
    property string windowTitle: ""
    // niri reports exactly one focused workspace globally, so this is the output
    // the user is actually looking at. Deriving it from the event stream lets the
    // drawer open synchronously instead of waiting on a `niri msg` subprocess.
    readonly property string focusedOutput: {
        const focused = root.workspaces.find(workspace => workspace.is_focused);
        return focused ? focused.output : "";
    }
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
    readonly property int barHeight: shellTheme.barHeight
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

    // Toggling the VPN takes a moment to settle. Without this the bar showed the
    // old state for up to a full 5s poll, so the natural response was to click
    // again — which toggled it straight back.
    function toggleMullvad() {
        root.mullvadStatus = {
            text: root.mullvadStatus.text,
            tone: "warning",
            tooltip: "Switching Mullvad…"
        };
        Quickshell.execDetached(["waybar-mullvad", "toggle"]);
        mullvadSettleTimer.ticks = 0;
        mullvadSettleTimer.restart();
    }

    function openNetworkSettings() {
        Quickshell.execDetached(["nm-connection-editor"]);
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

        root.drawerScreen = Quickshell.screens.find(screen => screen.name === root.focusedOutput) || Quickshell.screens[0];
        root.drawerMode = mode;
        root.drawerOpen = true;
    }

    // Paint the clicked workspace as focused immediately. niri confirms via the
    // event stream a moment later; without this the chip trailed the user's own
    // keystroke by up to a full poll interval.
    function setWorkspaceFocus(id) {
        root.workspaces = root.workspaces.map(workspace => Object.assign({}, workspace, {
                is_focused: workspace.id === id
            }));
    }

    function activateWorkspace(outputName, idx) {
        const target = root.workspaces.find(workspace => workspace.output === outputName && workspace.idx === idx);
        if (target)
            root.setWorkspaceFocus(target.id);
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]);
    }

    function handleNiriEvent(line) {
        let event;
        try {
            event = JSON.parse(line);
        } catch (error) {
            return;
        }

        niriEventRestartTimer.backoff = 1000;

        if (event.WorkspacesChanged) {
            root.workspaces = event.WorkspacesChanged.workspaces || [];
            return;
        }

        if (event.WorkspaceActivated) {
            if (event.WorkspaceActivated.focused)
                root.setWorkspaceFocus(event.WorkspaceActivated.id);
            return;
        }

        if (event.WorkspaceUrgencyChanged) {
            const urgency = event.WorkspaceUrgencyChanged;
            root.workspaces = root.workspaces.map(workspace => workspace.id === urgency.id ? Object.assign({}, workspace, {
                    is_urgent: urgency.urgent
                }) : workspace);
            return;
        }

        if (event.WindowsChanged) {
            const titles = {};
            let focused = -1;
            const windows = event.WindowsChanged.windows || [];
            for (let index = 0; index < windows.length; ++index) {
                titles[windows[index].id] = windows[index].title || "";
                if (windows[index].is_focused)
                    focused = windows[index].id;
            }
            root.windowTitles = titles;
            root.focusedWindowId = focused;
            root.windowTitle = focused >= 0 ? titles[focused] : "";
            return;
        }

        if (event.WindowOpenedOrChanged) {
            const changed = event.WindowOpenedOrChanged.window;
            if (!changed)
                return;

            root.windowTitles[changed.id] = changed.title || "";
            if (changed.is_focused)
                root.focusedWindowId = changed.id;
            if (changed.id === root.focusedWindowId)
                root.windowTitle = changed.title || "";
            return;
        }

        if (event.WindowFocusChanged) {
            const focusedId = event.WindowFocusChanged.id;
            root.focusedWindowId = focusedId === null || focusedId === undefined ? -1 : focusedId;
            root.windowTitle = root.windowTitles[root.focusedWindowId] || "";
            return;
        }

        if (event.WindowClosed) {
            const closedId = event.WindowClosed.id;
            delete root.windowTitles[closedId];
            if (root.focusedWindowId === closedId) {
                root.focusedWindowId = -1;
                root.windowTitle = "";
            }
        }
    }

    Process {
        id: niriEventProcess

        command: ["niri", "msg", "-j", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => root.handleNiriEvent(line)
        }
        // The stream is the only source of workspace and window state, so a
        // compositor restart must not leave the bar frozen on stale data.
        onExited: niriEventRestartTimer.restart()
    }

    Timer {
        id: niriEventRestartTimer

        // Back off, so a compositor that never returns can't turn this into a
        // 1 Hz fork loop. handleNiriEvent resets it once a line actually lands.
        property int backoff: 1000

        interval: niriEventRestartTimer.backoff
        onTriggered: {
            niriEventRestartTimer.backoff = Math.min(niriEventRestartTimer.backoff * 2, 30000);
            niriEventProcess.running = true;
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
                    // Never put raw helper output in the bar: it has no bound,
                    // and a multi-line stderr dump collapses the window title.
                    // The label stays fixed; the detail goes to the tooltip.
                    root.mullvadStatus = {
                        text: "󰖂 VPN unavailable",
                        tone: "danger",
                        tooltip: "Mullvad status unavailable" + (text.trim() ? " — " + text.trim().split("\n")[0] : "")
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

    Timer {
        id: mullvadSettleTimer

        property int ticks: 0

        interval: 700
        repeat: true
        onTriggered: {
            mullvadProcess.running = true;
            if (++mullvadSettleTimer.ticks >= 5)
                mullvadSettleTimer.stop();
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
        margins.bottom: root.barHeight
        theme: shellTheme
        open: root.drawerOpen
        mode: root.drawerMode
        now: clock.date
        onDismissed: root.drawerOpen = false
        onModeRequested: mode => root.drawerMode = mode
        onShellActionRequested: action => {
            if (action === "mullvad")
                root.toggleMullvad();
            else if (action === "network")
                root.openNetworkSettings();
        }
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
            exclusiveZone: root.barHeight
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
            implicitHeight: root.barHeight
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: shellTheme.background

                // Only the top edge is ever visible — the other three sit against
                // the screen bezel, so a four-sided border drew three lines nobody
                // could see and stole a pixel of height from the content.
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 1
                    color: shellTheme.border
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Modules.WorkspaceList {
                        workspaces: root.workspaces
                        screenName: bar.screen.name
                        theme: shellTheme
                        onFocusWorkspace: index => root.activateWorkspace(bar.screen.name, index)
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
                        onMullvadClicked: root.toggleMullvad()
                        onCellularClicked: root.openNetworkSettings()
                        onBacklightClicked: root.toggleBrightness(bar.screen)
                        onBacklightWheel: increase => root.adjustBrightness(increase)
                    }
                }
            }
        }
    }
}
