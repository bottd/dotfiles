import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    required property var screen
    required property var theme
    required property bool open
    required property string mode
    property bool presented: false
    property var path: []
    property int selectedIndex: 0
    property var applicationIndex: DesktopEntries.applications.values
    property alias query: search.text
    signal dismissed
    signal modeRequested(string mode)

    readonly property var menu: [
        {
            key: "f",
            label: "Focus",
            description: "Move focus",
            items: [
                {
                    key: "h",
                    label: "Focus left",
                    action: "focus-column-left"
                },
                {
                    key: "l",
                    label: "Focus right",
                    action: "focus-column-right"
                },
                {
                    key: "j",
                    label: "Focus down",
                    action: "focus-window-down"
                },
                {
                    key: "k",
                    label: "Focus up",
                    action: "focus-window-up"
                },
                {
                    key: "m",
                    label: "Focus floating/tiling",
                    action: "switch-focus-between-floating-and-tiling"
                }
            ]
        },
        {
            key: "m",
            label: "Move",
            description: "Move columns and windows",
            items: [
                {
                    key: "h",
                    label: "Move column left",
                    action: "move-column-left"
                },
                {
                    key: "l",
                    label: "Move column right",
                    action: "move-column-right"
                },
                {
                    key: "j",
                    label: "Move window down",
                    action: "move-window-down"
                },
                {
                    key: "k",
                    label: "Move window up",
                    action: "move-window-up"
                },
                {
                    key: "H",
                    label: "Move to monitor left",
                    action: "move-window-to-monitor-left"
                },
                {
                    key: "L",
                    label: "Move to monitor right",
                    action: "move-window-to-monitor-right"
                }
            ]
        },
        {
            key: "w",
            label: "Workspace",
            description: "Switch workspace",
            items: [
                {
                    key: "u",
                    label: "Previous workspace",
                    action: "focus-workspace-down"
                },
                {
                    key: "i",
                    label: "Next workspace",
                    action: "focus-workspace-up"
                }
            ].concat(Array.from({
                length: 9
            }, (_, index) => ({
                        key: String(index + 1),
                        label: "Workspace " + String(index + 1),
                        action: "focus-workspace",
                        arguments: [String(index + 1)]
                    })))
        },
        {
            key: "s",
            label: "Layout",
            description: "Size and arrangement",
            items: [
                {
                    key: "f",
                    label: "Maximize column",
                    action: "maximize-column"
                },
                {
                    key: "F",
                    label: "Fullscreen window",
                    action: "fullscreen-window"
                },
                {
                    key: "c",
                    label: "Center column",
                    action: "center-column"
                },
                {
                    key: "r",
                    label: "Cycle column width",
                    action: "switch-preset-column-width"
                },
                {
                    key: "-",
                    label: "Narrow column",
                    action: "set-column-width",
                    arguments: ["-10%"]
                },
                {
                    key: "=",
                    label: "Widen column",
                    action: "set-column-width",
                    arguments: ["+10%"]
                },
                {
                    key: "t",
                    label: "Toggle floating",
                    action: "toggle-window-floating"
                }
            ]
        },
        {
            key: "p",
            label: "Power",
            description: "Session actions",
            items: [
                {
                    key: "s",
                    label: "Sleep",
                    command: ["systemctl", "suspend"]
                },
                {
                    key: "r",
                    label: "Reboot",
                    command: ["systemctl", "reboot"]
                },
                {
                    key: "o",
                    label: "Power off",
                    command: ["systemctl", "poweroff"]
                },
                {
                    key: "l",
                    label: "Lock",
                    command: ["swaylock"]
                }
            ]
        },
        {
            key: "a",
            label: "Airplane mode",
            description: "Toggle all radios",
            command: ["sh", "-c", "if LC_ALL=C rfkill -n -o SOFT | grep -q unblocked; then rfkill block all; else rfkill unblock all; fi"]
        },
        {
            key: "d",
            label: "Launcher",
            description: "Search applications",
            targetMode: "launcher"
        },
        {
            key: "q",
            label: "Close window",
            description: "Close the focused window",
            action: "close-window"
        },
        {
            key: "e",
            label: "Exit Niri",
            description: "Quit the compositor",
            action: "quit"
        }
    ]

    readonly property var activeItems: root.path.length === 0 ? root.menu : root.path[root.path.length - 1].items
    readonly property string breadcrumb: root.path.length === 0 ? "COMMAND MENU" : root.path.map(item => item.label).join("  /  ")
    readonly property var filteredApplications: {
        const needle = root.query.trim().toLowerCase();
        if (needle === "")
            return root.applicationIndex;

        return root.applicationIndex.map((entry, index) => ({
                    entry: entry,
                    index: index,
                    score: root.applicationScore(needle, entry)
                })).filter(candidate => candidate.score > Number.NEGATIVE_INFINITY).sort((a, b) => b.score - a.score || a.index - b.index).map(candidate => candidate.entry);
    }

    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    screen: root.screen
    margins.bottom: 10
    margins.left: 10
    margins.right: 10
    implicitHeight: Math.min(320, root.screen.height * 0.45)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: root.presented
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "drake-command-drawer"

    function fuzzyScore(needle, value) {
        const text = (value || "").toLowerCase();
        let score = 0;
        let previous = -1;
        let first = -1;

        for (let index = 0; index < needle.length; ++index) {
            const position = text.indexOf(needle[index], previous + 1);
            if (position < 0)
                return Number.NEGATIVE_INFINITY;

            if (first < 0)
                first = position;

            const boundary = position === 0 || " -_./".includes(text[position - 1]);
            score += 1 + (boundary ? 8 : 0);
            if (previous >= 0) {
                score += position === previous + 1 ? 6 : 0;
                score -= Math.max(0, position - previous - 1);
            }
            previous = position;
        }

        if (text === needle)
            score += 100;
        else if (text.startsWith(needle))
            score += 30;
        else if (text.includes(needle))
            score += 15;

        return score - first * 0.5 - (text.length - needle.length) * 0.05;
    }

    function applicationScore(needle, entry) {
        return Math.max(root.fuzzyScore(needle, entry.name), root.fuzzyScore(needle, entry.genericName) - 10, root.fuzzyScore(needle, entry.keywords.join(" ")) - 15, root.fuzzyScore(needle, entry.comment) - 25);
    }

    function focusCurrentMode() {
        if (root.mode === "launcher")
            search.forceActiveFocus();
        else
            drawer.forceActiveFocus();
    }

    function moveDrawer(target, closing) {
        slide.stop();
        if (!root.theme.animationsEnabled) {
            drawer.y = target;
            if (closing)
                root.presented = false;
            return;
        }

        slide.to = target;
        slide.start();
    }

    function close() {
        root.dismissed();
    }

    function goBack() {
        if (root.path.length === 0) {
            root.close();
            return;
        }

        root.path = root.path.slice(0, -1);
    }

    function activate(item) {
        if (item.items) {
            root.path = root.path.concat([item]);
            return;
        }

        if (item.targetMode) {
            root.modeRequested(item.targetMode);
            return;
        }

        if (item.action)
            Quickshell.execDetached(["niri", "msg", "action", item.action].concat(item.arguments || []));
        else if (item.command)
            Quickshell.execDetached(item.command);
        root.close();
    }

    function launchSelected() {
        const entry = root.filteredApplications[root.selectedIndex];
        if (!entry)
            return;

        Quickshell.execDetached(root.theme.launcherCommand.concat([entry.id]));
        root.close();
    }

    function keyName(event) {
        if (event.key === Qt.Key_Space)
            return "Space";
        if (event.key === Qt.Key_Tab)
            return "Tab";
        if (event.key === Qt.Key_Print)
            return "Print";
        return event.text;
    }

    function handleCommandKey(event) {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) {
            root.goBack();
            event.accepted = true;
            return;
        }

        const key = root.keyName(event);
        const item = root.activeItems.find(candidate => candidate.key === key);
        if (item) {
            root.activate(item);
            event.accepted = true;
        }
    }

    onOpenChanged: {
        if (root.open) {
            root.presented = true;
            root.path = [];
            root.selectedIndex = 0;
            if (root.mode === "launcher")
                root.query = "";
            drawer.y = root.theme.animationsEnabled ? root.height : 0;
            Qt.callLater(function () {
                root.moveDrawer(0, false);
                root.focusCurrentMode();
            });
        } else if (root.presented) {
            root.moveDrawer(root.height, true);
        }
    }

    onModeChanged: {
        root.path = [];
        root.selectedIndex = 0;
        if (root.mode === "launcher")
            root.query = "";
        if (root.open)
            Qt.callLater(root.focusCurrentMode);
    }

    Component.onCompleted: drawer.y = root.height

    Connections {
        target: DesktopEntries

        function onApplicationsChanged() {
            root.applicationIndex = DesktopEntries.applications.values;
        }
    }

    ShortcutInhibitor {
        window: root
        enabled: root.open
    }

    NumberAnimation {
        id: slide

        target: drawer
        property: "y"
        duration: 170
        easing.type: Easing.OutCubic
        onFinished: {
            if (!root.open)
                root.presented = false;
        }
    }

    FocusScope {
        id: keyboard

        anchors.fill: parent
        focus: root.open
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_F13) {
                event.accepted = true;
                return;
            }
            if (root.mode === "commands")
                root.handleCommandKey(event);
        }
        Keys.onReleased: function (event) {
            if (event.key === Qt.Key_F13) {
                root.close();
                event.accepted = true;
            }
        }

        Rectangle {
            id: drawer

            width: parent.width
            height: parent.height
            radius: 8
            color: root.theme.base00
            border.color: root.theme.base0D
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.mode === "launcher" ? "APPLICATIONS" : root.breadcrumb
                        color: root.theme.base0D
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.mode === "launcher" ? "BACKSPACE on empty returns  /  SUPER closes" : "ESC back  /  SUPER closes"
                        color: root.theme.base03
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize - 1
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Flow {
                        anchors.fill: parent
                        visible: root.mode === "commands"
                        spacing: 8

                        Repeater {
                            model: root.activeItems

                            delegate: Rectangle {
                                required property var modelData

                                width: Math.max(150, commandLabel.implicitWidth + commandKey.implicitWidth + 42)
                                height: 56
                                radius: 6
                                color: commandMouse.containsMouse ? root.theme.base02 : root.theme.base01
                                border.color: commandMouse.containsMouse ? root.theme.base0D : root.theme.base02
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    Text {
                                        id: commandKey

                                        text: modelData.key
                                        color: root.theme.base0D
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSize + 2
                                        font.bold: true
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            id: commandLabel

                                            Layout.fillWidth: true
                                            text: modelData.label
                                            elide: Text.ElideRight
                                            color: root.theme.base05
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.items ? "+ " + modelData.description : modelData.description
                                            elide: Text.ElideRight
                                            color: root.theme.base03
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize - 2
                                        }
                                    }
                                }

                                MouseArea {
                                    id: commandMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.activate(modelData)
                                }
                            }
                        }
                    }

                    ListView {
                        id: results

                        anchors.fill: parent
                        visible: root.mode === "launcher"
                        clip: true
                        spacing: 3
                        model: root.filteredApplications

                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            width: results.width
                            height: 40
                            radius: 5
                            color: index === root.selectedIndex ? root.theme.base02 : "transparent"

                            IconImage {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 22
                                implicitHeight: 22
                                source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 40
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                elide: Text.ElideRight
                                color: root.theme.base05
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.selectedIndex = index;
                                    root.launchSelected();
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.filteredApplications.length === 0
                            text: "No applications found"
                            color: root.theme.base03
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSize
                        }
                    }
                }

                TextField {
                    id: search

                    Layout.fillWidth: true
                    visible: root.mode === "launcher"
                    placeholderText: "Search applications"
                    selectByMouse: true
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                    color: root.theme.base05
                    placeholderTextColor: root.theme.base03
                    background: Rectangle {
                        radius: 6
                        color: root.theme.base01
                        border.color: root.theme.base02
                        border.width: 1
                    }
                    onTextChanged: root.selectedIndex = 0
                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Escape) {
                            root.close();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Backspace && search.text === "") {
                            root.modeRequested("commands");
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchSelected();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
                            if (root.filteredApplications.length === 0) {
                                event.accepted = true;
                                return;
                            }
                            root.selectedIndex = Math.min(root.selectedIndex + 1, root.filteredApplications.length - 1);
                            results.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
                            if (root.filteredApplications.length === 0) {
                                event.accepted = true;
                                return;
                            }
                            root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                            results.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }
}
