import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var screen
    required property var theme
    required property bool open
    property var path: []
    signal dismissed
    readonly property bool active: root.open

    readonly property var menu: [
        {
            key: "f",
            label: "Focus",
            description: "Move focus",
            items: [
                {
                    key: "h",
                    label: "Focus left",
                    command: ["niri", "msg", "action", "focus-column-left"]
                },
                {
                    key: "l",
                    label: "Focus right",
                    command: ["niri", "msg", "action", "focus-column-right"]
                },
                {
                    key: "j",
                    label: "Focus down",
                    command: ["niri", "msg", "action", "focus-window-down"]
                },
                {
                    key: "k",
                    label: "Focus up",
                    command: ["niri", "msg", "action", "focus-window-up"]
                },
                {
                    key: "m",
                    label: "Focus floating/tiling",
                    command: ["niri", "msg", "action", "switch-focus-between-floating-and-tiling"]
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
                    command: ["niri", "msg", "action", "move-column-left"]
                },
                {
                    key: "l",
                    label: "Move column right",
                    command: ["niri", "msg", "action", "move-column-right"]
                },
                {
                    key: "j",
                    label: "Move window down",
                    command: ["niri", "msg", "action", "move-window-down"]
                },
                {
                    key: "k",
                    label: "Move window up",
                    command: ["niri", "msg", "action", "move-window-up"]
                },
                {
                    key: "H",
                    label: "Move to monitor left",
                    command: ["niri", "msg", "action", "move-window-to-monitor-left"]
                },
                {
                    key: "L",
                    label: "Move to monitor right",
                    command: ["niri", "msg", "action", "move-window-to-monitor-right"]
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
                    command: ["niri", "msg", "action", "focus-workspace-down"]
                },
                {
                    key: "i",
                    label: "Next workspace",
                    command: ["niri", "msg", "action", "focus-workspace-up"]
                },
                {
                    key: "1",
                    label: "Workspace 1",
                    command: ["niri", "msg", "action", "focus-workspace", "1"]
                },
                {
                    key: "2",
                    label: "Workspace 2",
                    command: ["niri", "msg", "action", "focus-workspace", "2"]
                },
                {
                    key: "3",
                    label: "Workspace 3",
                    command: ["niri", "msg", "action", "focus-workspace", "3"]
                },
                {
                    key: "4",
                    label: "Workspace 4",
                    command: ["niri", "msg", "action", "focus-workspace", "4"]
                },
                {
                    key: "5",
                    label: "Workspace 5",
                    command: ["niri", "msg", "action", "focus-workspace", "5"]
                },
                {
                    key: "6",
                    label: "Workspace 6",
                    command: ["niri", "msg", "action", "focus-workspace", "6"]
                },
                {
                    key: "7",
                    label: "Workspace 7",
                    command: ["niri", "msg", "action", "focus-workspace", "7"]
                },
                {
                    key: "8",
                    label: "Workspace 8",
                    command: ["niri", "msg", "action", "focus-workspace", "8"]
                },
                {
                    key: "9",
                    label: "Workspace 9",
                    command: ["niri", "msg", "action", "focus-workspace", "9"]
                }
            ]
        },
        {
            key: "s",
            label: "Layout",
            description: "Size and arrangement",
            items: [
                {
                    key: "f",
                    label: "Maximize column",
                    command: ["niri", "msg", "action", "maximize-column"]
                },
                {
                    key: "F",
                    label: "Fullscreen window",
                    command: ["niri", "msg", "action", "fullscreen-window"]
                },
                {
                    key: "c",
                    label: "Center column",
                    command: ["niri", "msg", "action", "center-column"]
                },
                {
                    key: "r",
                    label: "Cycle column width",
                    command: ["niri", "msg", "action", "switch-preset-column-width"]
                },
                {
                    key: "-",
                    label: "Narrow column",
                    command: ["niri", "msg", "action", "set-column-width", "-10%"]
                },
                {
                    key: "=",
                    label: "Widen column",
                    command: ["niri", "msg", "action", "set-column-width", "+10%"]
                },
                {
                    key: "t",
                    label: "Toggle floating",
                    command: ["niri", "msg", "action", "toggle-window-floating"]
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
            description: "Open applications",
            command: ["qs", "ipc", "call", "launcher", "toggle"]
        },
        {
            key: "q",
            label: "Close window",
            description: "Close the focused window",
            command: ["niri", "msg", "action", "close-window"]
        },
        {
            key: "e",
            label: "Exit Niri",
            description: "Quit the compositor",
            command: ["niri", "msg", "action", "quit"]
        }
    ]

    readonly property var activeItems: root.path.length === 0 ? root.menu : root.path[root.path.length - 1].items
    readonly property string breadcrumb: root.path.length === 0 ? "COMMAND MENU" : root.path.map(item => item.label).join("  /  ")

    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    screen: root.screen
    margins.bottom: 10
    margins.left: 10
    margins.right: 10
    implicitHeight: 190
    exclusiveZone: 0
    color: "transparent"
    visible: root.active
    WlrLayershell.keyboardFocus: root.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "drake-key-overlay"

    function close() {
        root.path = [];
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

        if (item.command)
            Quickshell.execDetached(item.command);
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

    function handleKey(event) {
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
        if (root.active) {
            root.path = [];
            Qt.callLater(keyboard.forceActiveFocus);
        } else {
            root.path = [];
        }
    }

    onVisibleChanged: {
        if (visible)
            Qt.callLater(keyboard.forceActiveFocus);
    }

    ShortcutInhibitor {
        window: root
        enabled: root.open
    }

    FocusScope {
        id: keyboard

        anchors.fill: parent
        focus: root.active
        Keys.onPressed: function (event) {
            root.handleKey(event);
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: root.theme.base00
            border.color: root.theme.base0D
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.breadcrumb
                        color: root.theme.base0D
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "ESC back  /  BACKSPACE back"
                        color: root.theme.base03
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize - 1
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    Repeater {
                        model: root.activeItems

                        delegate: Rectangle {
                            required property var modelData

                            width: Math.max(150, label.implicitWidth + key.implicitWidth + 42)
                            height: 56
                            radius: 6
                            color: mouse.containsMouse ? root.theme.base02 : root.theme.base01
                            border.color: mouse.containsMouse ? root.theme.base0D : root.theme.base02
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    id: key
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
                                        id: label
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
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.activate(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
