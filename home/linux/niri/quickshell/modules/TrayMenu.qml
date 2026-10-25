import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    required property var theme
    property var trayItem: null
    property var stack: []
    property int selectedIndex: -1
    readonly property var currentOpener: stack.length ? stack[stack.length - 1].opener : topMenu
    readonly property var entries: currentOpener.children.values
    readonly property string title: stack.length ? stack[stack.length - 1].title : (trayItem ? trayItem.tooltipTitle || trayItem.title || trayItem.id : "")

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: trayItem !== null && trayItem.hasMenu
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "drake-tray-menu"

    function show(item) {
        close();
        trayItem = item;
        menuPanel.printIn();
        Qt.callLater(() => {
            navigationFocus.forceActiveFocus();
        });
    }
    function close() {
        const oldStack = stack;
        stack = [];
        for (let i = oldStack.length - 1; i >= 0; --i)
            oldStack[i].opener.destroy();
        trayItem = null;
        selectedIndex = -1;
    }
    function back() {
        if (!stack.length) {
            close();
            return;
        }
        const last = stack[stack.length - 1];
        selectedIndex = -1;
        stack = stack.slice(0, -1);
        last.opener.destroy();
    }
    function label(text) {
        // QsMenuEntry.text already removes DBusMenu mnemonic markers.
        return text;
    }
    function selectNext(direction) {
        const start = selectedIndex < 0 && direction < 0 ? 0 : selectedIndex;
        for (let offset = 1; offset <= entries.length; ++offset) {
            const index = (start + direction * offset + entries.length) % entries.length;
            if (entries[index].enabled && !entries[index].isSeparator) {
                selectedIndex = index;
                list.positionViewAtIndex(index, ListView.Contain);
                return;
            }
        }
        selectedIndex = -1;
    }
    function activate(entry) {
        if (!entry || !entry.enabled || entry.isSeparator)
            return;
        if (entry.hasChildren) {
            const opener = submenuFactory.createObject(root, {
                menu: entry
            });
            selectedIndex = -1;
            stack = stack.concat([
                {
                    opener: opener,
                    title: label(entry.text)
                }
            ]);
        } else {
            entry.triggered();
            close();
        }
    }
    function handleKey(event) {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Left || event.key === Qt.Key_Backspace) {
            if (!event.isAutoRepeat)
                back();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
            selectNext(event.key === Qt.Key_Down ? 1 : -1);
            navigationFocus.forceActiveFocus();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space || event.key === Qt.Key_Right) {
            const entry = entries[selectedIndex];
            if (event.key !== Qt.Key_Right || (entry && entry.hasChildren))
                activate(entry);
            event.accepted = true;
        }
    }
    onEntriesChanged: {
        if (selectedIndex < 0 || selectedIndex >= entries.length || !entries[selectedIndex].enabled || entries[selectedIndex].isSeparator) {
            selectedIndex = -1;
            selectNext(1);
        }
    }
    onVisibleChanged: {
        if (!visible && trayItem !== null)
            close();
    }
    QsMenuOpener {
        id: topMenu
        menu: root.visible ? root.trayItem.menu : null
    }
    Component {
        id: submenuFactory
        QsMenuOpener {
            onMenuChanged: {
                if (!menu)
                    Qt.callLater(() => {
                        while (root.stack.length && !root.currentOpener.menu)
                            root.back();
                    });
            }
        }
    }
    Timer {
        id: pointerGuard
        interval: Qt.styleHints.mouseDoubleClickInterval
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }
    FocusScope {
        id: menuKeys
        anchors.fill: parent
        focus: root.visible
        Item {
            id: navigationFocus
        }
        Keys.onPressed: event => root.handleKey(event)
        PressPanel {
            id: menuPanel
            theme: root.theme
            anchors.centerIn: parent
            width: Math.min(parent.width - root.theme.fontSize * 4, root.theme.fontSize * 38)
            height: Math.min(parent.height - root.theme.fontSize * 4, Math.max(root.theme.fontSize * 14, list.contentHeight + root.theme.fontSize * 10))
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.inset
                spacing: root.theme.gap
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: root.title.toUpperCase()
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: root.theme.ink
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.headingSize
                        font.bold: true
                    }
                    PressButton {
                        id: backButton
                        theme: root.theme
                        implicitWidth: root.theme.fontSize * 7
                        Accessible.name: root.stack.length ? "Back" : "Close menu"
                        onClicked: root.back()
                        Text {
                            anchors.centerIn: parent
                            text: root.stack.length ? "BACK" : "CLOSE"
                            color: backButton.foreground
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSize
                            font.bold: true
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: root.theme.ruleWidth * 2
                    color: root.theme.ink
                }
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: root.theme.pressOffset
                    model: root.entries
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: list.width - root.theme.fontSize
                        height: modelData.isSeparator ? root.theme.fontSize : root.theme.rowHeight + root.theme.pressOffset
                        Rectangle {
                            visible: modelData.isSeparator
                            width: parent.width
                            height: root.theme.ruleWidth
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.theme.ink
                        }
                        PressButton {
                            id: entryButton
                            activeFocusOnTab: false
                            anchors.fill: parent
                            theme: root.theme
                            visible: !modelData.isSeparator
                            enabled: modelData.enabled
                            selected: index === root.selectedIndex
                            Accessible.name: root.label(modelData.text)
                            Accessible.checkable: modelData.buttonType !== QsMenuButtonType.None
                            Accessible.checked: modelData.checkState === Qt.Checked
                            onClicked: {
                                if (!root.visible || pointerGuard.running)
                                    return;
                                pointerGuard.restart();
                                root.activate(modelData);
                            }
                            Keys.onPressed: event => root.handleKey(event)
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: root.theme.ruleWidth * 3
                                anchors.rightMargin: root.theme.ruleWidth * 3
                                spacing: root.theme.gap
                                Rectangle {
                                    visible: modelData.buttonType !== QsMenuButtonType.None
                                    implicitWidth: root.theme.fontSize
                                    implicitHeight: width
                                    radius: modelData.buttonType === QsMenuButtonType.RadioButton ? width / 2 : 0
                                    color: "transparent"
                                    border.color: entryButton.foreground
                                    border.width: root.theme.ruleWidth
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width - root.theme.ruleWidth * 3
                                        height: modelData.checkState === Qt.PartiallyChecked ? root.theme.ruleWidth : width
                                        radius: parent.radius
                                        visible: modelData.checkState !== Qt.Unchecked
                                        color: entryButton.foreground
                                    }
                                }
                                IconImage {
                                    visible: modelData.icon !== ""
                                    source: modelData.icon
                                    implicitWidth: root.theme.iconSize
                                    implicitHeight: root.theme.iconSize
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.label(modelData.text)
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                    color: entryButton.foreground
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize
                                }
                                Text {
                                    visible: modelData.hasChildren
                                    text: "›"
                                    color: entryButton.foreground
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.headingSize
                                    font.bold: true
                                }
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !root.entries.length
                        text: "No menu items"
                        color: root.theme.textMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize
                    }
                }
            }
        }
    }
}
