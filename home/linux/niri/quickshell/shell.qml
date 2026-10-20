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
    property var windowTitles: ({})
    property int focusedWindowId: -1
    property string windowTitle: ""
    readonly property string focusedOutput: {
        const focused = root.workspaces.find(workspace => workspace.is_focused);
        return focused ? focused.output : "";
    }
    property var vpnStatus: ({
            text: "",
            tone: "neutral",
            tooltip: ""
        })
    property var cellularStatus: ({
            text: "",
            tone: "neutral",
            tooltip: ""
        })
    readonly property string backlightText: root.backlightAvailable ? "󰃟 " + Math.round(root.brightnessLevel * 100) + "%" : ""
    property bool backlightAvailable: false
    property real measuredBrightnessLevel: 0
    property real requestedBrightnessLevel: -1
    property int brightnessRequestGeneration: 0
    property var pendingBrightnessCommands: []
    readonly property real brightnessLevel: root.requestedBrightnessLevel >= 0 ? root.requestedBrightnessLevel : root.measuredBrightnessLevel
    readonly property bool brightnessBusy: brightnessCommitTimer.running || brightnessWriteProcess.running || root.pendingBrightnessCommands.length > 0
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
    onAudioReadyChanged: {
        if (!audioReady)
            volumeOpen = false;
    }
    Connections {
        target: Quickshell
        function onScreensChanged() {
            if (!Quickshell.screens.includes(root.drawerScreen))
                root.drawerOpen = false;
            if (!Quickshell.screens.includes(root.volumeScreen))
                root.volumeOpen = false;
            if (!Quickshell.screens.includes(root.brightnessScreen))
                root.brightnessOpen = false;
        }
    }

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
            vpnProcess.running = true;
            cellularProcess.running = true;
        }
    }

    Timer {
        interval: root.brightnessOpen ? 2000 : 45000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshBrightness()
    }

    function focusedScreen() {
        return Quickshell.screens.find(screen => screen.name === root.focusedOutput) || Quickshell.screens[0];
    }

    // Media keys show a level without taking focus; KeyOverlay opens it to
    // drive from the keyboard.
    function showLevel(kind, keyboard) {
        const screen = root.focusedScreen();
        if (kind === "brightness") {
            root.refreshBrightness();
            if (!root.backlightAvailable)
                return;
            root.volumeOpen = false;
            brightnessPopup.keyboardDriven = keyboard;
            root.brightnessScreen = screen;
            root.brightnessOpen = true;
            brightnessPopup.poke();
        } else {
            if (!root.audioReady)
                return;
            root.brightnessOpen = false;
            volumePopup.keyboardDriven = keyboard;
            root.volumeScreen = screen;
            root.volumeOpen = true;
            volumePopup.poke();
        }
    }

    function toggleVolume(screen) {
        if (!root.audioReady)
            return;
        volumePopup.keyboardDriven = false;
        const closing = root.volumeOpen && root.volumeScreen === screen;
        root.brightnessOpen = false;
        root.volumeScreen = screen;
        root.volumeOpen = !closing;
    }

    function toggleBrightness(screen) {
        if (!root.backlightAvailable)
            return;

        brightnessPopup.keyboardDriven = false;
        const closing = root.brightnessOpen && root.brightnessScreen === screen;
        root.volumeOpen = false;
        root.brightnessScreen = screen;
        root.brightnessOpen = !closing;
    }

    function setBrightness(level) {
        if (!root.backlightAvailable)
            return;

        root.brightnessRequestGeneration++;
        root.requestedBrightnessLevel = Math.max(0, Math.min(1, level));
        root.pendingBrightnessCommands = [["brightness", "set", String(Math.round(root.requestedBrightnessLevel * 100))]];
        brightnessCommitTimer.restart();
    }

    function adjustBrightness(increase) {
        if (!root.backlightAvailable)
            return;

        root.setBrightness(root.brightnessLevel + (increase ? 0.05 : -0.05));
    }

    function commitBrightness() {
        if (brightnessCommitTimer.running || brightnessWriteProcess.running || root.pendingBrightnessCommands.length === 0)
            return;

        brightnessWriteProcess.command = root.pendingBrightnessCommands[0];
        root.pendingBrightnessCommands = root.pendingBrightnessCommands.slice(1);
        brightnessWriteProcess.running = true;
    }

    function refreshBrightness() {
        if (root.brightnessBusy || backlightProcess.running)
            return;

        backlightProcess.requestGeneration = root.brightnessRequestGeneration;
        backlightProcess.output = "";
        backlightProcess.running = true;
    }

    function toggleVpn() {
        root.vpnStatus = {
            text: root.vpnStatus.text,
            tone: "warning",
            tooltip: "Switching exit node…"
        };
        Quickshell.execDetached(["vpn", "toggle"]);
        vpnSettleTimer.ticks = 0;
        vpnSettleTimer.restart();
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
        root.volumeOpen = false;
        root.brightnessOpen = false;
        if (root.drawerOpen) {
            root.drawerOpen = root.drawerMode !== mode;
            root.drawerMode = mode;
            return;
        }

        root.drawerScreen = Quickshell.screens.find(screen => screen.name === root.focusedOutput) || Quickshell.screens[0];
        root.drawerMode = mode;
        root.drawerOpen = true;
    }

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

        // Keeps the workspace chips' occupied/empty state current; niri only
        // resends the full workspace list on structural changes.
        if (event.WorkspaceActiveWindowChanged) {
            const change = event.WorkspaceActiveWindowChanged;
            root.workspaces = root.workspaces.map(workspace => workspace.id === change.workspace_id ? Object.assign({}, workspace, {
                    active_window_id: change.active_window_id
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
        onExited: niriEventRestartTimer.restart()
    }

    Timer {
        id: niriEventRestartTimer

        property int backoff: 1000

        interval: niriEventRestartTimer.backoff
        onTriggered: {
            niriEventRestartTimer.backoff = Math.min(niriEventRestartTimer.backoff * 2, 30000);
            niriEventProcess.running = true;
        }
    }

    Process {
        id: vpnProcess
        command: ["vpn"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const value = JSON.parse(text);
                    const state = value.class || "daemon-down";
                    root.vpnStatus = {
                        text: value.text || "",
                        tone: root.connectionTone(state),
                        tooltip: value.tooltip || "VPN status unavailable"
                    };
                } catch (error) {
                    root.vpnStatus = {
                        text: "󰖂 VPN unavailable",
                        tone: "danger",
                        tooltip: "VPN status unavailable" + (text.trim() ? " — " + text.trim().split("\n")[0] : "")
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
                const state = value.match(/modem\.generic\.state\s*:\s*(.+)/);
                const signal = value.match(/modem\.generic\.signal-quality\.value\s*:\s*(.+)/);
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

        property int requestGeneration: -1
        property string output: ""

        command: ["brightness", "get"]
        stdout: StdioCollector {
            onStreamFinished: backlightProcess.output = text
        }
        onRunningChanged: {
            if (running)
                return;

            if (backlightProcess.requestGeneration === root.brightnessRequestGeneration && !root.brightnessBusy) {
                const percentage = parseInt(backlightProcess.output, 10);
                root.backlightAvailable = Number.isFinite(percentage);
                root.measuredBrightnessLevel = root.backlightAvailable ? percentage / 100 : 0;
                root.requestedBrightnessLevel = -1;
                if (!root.backlightAvailable)
                    root.brightnessOpen = false;
            }

            if (root.requestedBrightnessLevel >= 0)
                root.refreshBrightness();
        }
    }

    Timer {
        id: brightnessCommitTimer

        interval: 120
        onTriggered: root.commitBrightness()
    }

    Process {
        id: brightnessWriteProcess

        onRunningChanged: {
            if (!running) {
                root.commitBrightness();
                root.refreshBrightness();
            }
        }
    }

    Timer {
        id: vpnSettleTimer

        property int ticks: 0

        interval: 700
        repeat: true
        onTriggered: {
            vpnProcess.running = true;
            if (++vpnSettleTimer.ticks >= 5)
                vpnSettleTimer.stop();
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggleDrawer("launcher");
        }
    }

    IpcHandler {
        target: "levels"

        function volume(): void {
            root.showLevel("volume", false);
        }
        function brightness(): void {
            root.showLevel("brightness", false);
        }
    }

    IpcHandler {
        target: "key-overlay"

        function toggle(): void {
            root.toggleDrawer("commands");
        }
    }

    Modules.VolumePopup {
        id: volumePopup

        screen: root.volumeScreen || Quickshell.screens[0]
        theme: shellTheme
        open: root.volumeOpen
        level: root.volumeLevel
        muted: root.volumeMuted
        onSetVolume: level => {
            if (root.audioReady)
                root.audioSink.audio.volume = Math.max(0, Math.min(Math.max(1, root.volumeLevel), level));
        }
        onToggleMute: {
            if (root.audioReady)
                root.audioSink.audio.muted = !root.audioSink.audio.muted;
        }
        onDismissed: root.volumeOpen = false
    }

    Modules.BrightnessPopup {
        id: brightnessPopup

        screen: root.brightnessScreen || Quickshell.screens[0]
        theme: shellTheme
        open: root.brightnessOpen
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
        onShellActionRequested: (action, keyboard) => {
            if (action === "vpn")
                root.toggleVpn();
            else if (action === "network")
                root.openNetworkSettings();
            else if (action === "volume" || action === "brightness")
                root.showLevel(action, keyboard);
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
            exclusiveZone: root.barHeight + shellTheme.seamHeight
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
            // Reserve the whole painted area; the seam stays click-through.
            implicitHeight: root.barHeight + shellTheme.seamHeight
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            mask: Region {
                item: barSurface
            }

            Modules.DitherSeam {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: shellTheme.seamHeight
                cell: shellTheme.seamCell
                color: shellTheme.background
            }

            Rectangle {
                id: barSurface

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: root.barHeight
                color: shellTheme.background

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: shellTheme.ruleWidth
                    color: shellTheme.ink
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Math.round(shellTheme.fontSize * 0.85) // 10
                    anchors.rightMargin: Math.round(shellTheme.fontSize * 0.85) // 10
                    spacing: Math.round(shellTheme.fontSize * 0.67) // 8

                    Modules.WorkspaceList {
                        workspaces: root.workspaces
                        screenName: bar.screen.name
                        theme: shellTheme
                        onFocusWorkspace: index => root.activateWorkspace(bar.screen.name, index)
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.topMargin: shellTheme.ruleWidth * 3
                        Layout.bottomMargin: shellTheme.ruleWidth * 2
                        implicitWidth: shellTheme.ruleWidth
                        color: shellTheme.ink
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.windowTitle
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: shellTheme.textPrimary
                        font.family: shellTheme.fontFamily
                        font.pixelSize: shellTheme.fontSize
                    }

                    Modules.SystemTray {
                        overlayOpen: root.drawerOpen
                        parentWindow: bar
                        theme: shellTheme
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.topMargin: shellTheme.ruleWidth * 3
                        Layout.bottomMargin: shellTheme.ruleWidth * 2
                        implicitWidth: shellTheme.ruleWidth
                        color: shellTheme.ink
                    }

                    Modules.StatusModules {
                        audioStatus: root.audioStatus
                        vpnStatus: root.vpnStatus
                        cellularStatus: root.cellularStatus
                        backlightText: root.backlightText
                        battery: root.battery
                        now: clock.date
                        theme: shellTheme
                        onAudioClicked: root.toggleVolume(bar.screen)
                        onVpnClicked: root.toggleVpn()
                        onCellularClicked: root.openNetworkSettings()
                        onBacklightClicked: root.toggleBrightness(bar.screen)
                        onBacklightWheel: increase => root.adjustBrightness(increase)
                    }
                }
            }
        }
    }
}
