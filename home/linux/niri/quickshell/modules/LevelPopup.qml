import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var theme
    required property real level
    required property string title
    required property string panelNamespace
    property bool showMute: false
    property bool muted: false
    // Owners drive `open`; the window stays presented until the panel lifts out.
    property bool open: false
    property bool presented: false
    // Opened from the keyboard (KeyOverlay): take focus, stay until Esc.
    property bool keyboardDriven: false
    readonly property bool interacting: popupHover.hovered || slider.dragging || keyboardDriven
    signal moved(real level)
    signal toggleMute
    signal dismissed

    anchors.bottom: true
    anchors.right: true
    anchors.top: keyboardDriven
    anchors.left: keyboardDriven
    margins.bottom: keyboardDriven ? 0 : theme.barHeight + theme.seamHeight + theme.overlayGap
    margins.right: keyboardDriven ? 0 : Math.min(theme.overlayEdgeMargin, Math.max(0, (screen.width - implicitWidth) / 2))
    implicitWidth: Math.min(theme.fontSize * 28, screen.width - theme.fontSize * 2)
    implicitHeight: theme.fontSize * (keyboardDriven ? 13 : 11)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: presented
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: keyboardDriven && open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: panelNamespace

    function resetDismissal() {
        dismissTimer.stop();
        if (open && !interacting)
            dismissTimer.start();
    }
    // A repeated media key keeps the popup up for another full interval.
    function poke() {
        resetDismissal();
    }
    onOpenChanged: {
        if (open) {
            presented = true;
            panel.printIn();
            if (keyboardDriven)
                Qt.callLater(() => slider.forceActiveFocus());
        } else
            panel.pressOut();
        resetDismissal();
    }
    onKeyboardDrivenChanged: {
        if (keyboardDriven && open)
            Qt.callLater(() => slider.forceActiveFocus());
        resetDismissal();
    }
    onVisibleChanged: resetDismissal()
    onScreenChanged: resetDismissal()
    onInteractingChanged: resetDismissal()
    Component.onCompleted: resetDismissal()

    Timer {
        id: dismissTimer
        interval: 3000
        onTriggered: root.dismissed()
    }
    HoverHandler {
        id: popupHover
        parent: panel
    }
    MouseArea {
        anchors.fill: parent
        enabled: root.keyboardDriven && root.open
        onClicked: root.dismissed()
    }
    PressPanel {
        id: panel
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: root.keyboardDriven ? root.theme.barHeight + root.theme.seamHeight + root.theme.overlayGap : 0
        anchors.rightMargin: root.keyboardDriven ? Math.min(root.theme.overlayEdgeMargin, Math.max(0, (root.width - width) / 2)) : 0
        width: root.implicitWidth
        height: root.implicitHeight
        theme: root.theme
        onPressedOut: {
            if (!root.open)
                root.presented = false;
        }
        Keys.onEscapePressed: root.dismissed()
        Keys.onPressed: event => {
            if (root.showMute && event.text.toLowerCase() === "m") {
                root.toggleMute();
                event.accepted = true;
            }
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.theme.fontSize * 1.5
            spacing: root.theme.fontSize
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: root.title.toUpperCase()
                    elide: Text.ElideRight
                    color: root.theme.ink
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.headingSize
                    font.bold: true
                }
                Text {
                    text: root.muted ? "MUTED" : Math.round(root.level * 100) + "%"
                    color: root.theme.ink
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                    font.bold: true
                }
            }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: root.theme.ruleWidth
                color: root.theme.ink
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.fontSize
                LevelSlider {
                    id: slider
                    Layout.fillWidth: true
                    theme: root.theme
                    value: root.level
                    accessibleName: root.title
                    onMoved: value => {
                        root.moved(value);
                        root.resetDismissal();
                    }
                }
                PressButton {
                    id: muteButton
                    theme: root.theme
                    visible: root.showMute
                    implicitWidth: root.theme.fontSize * 7
                    selected: root.muted
                    Accessible.name: root.muted ? "Unmute" : "Mute"
                    onClicked: {
                        root.toggleMute();
                        root.resetDismissal();
                    }
                    Text {
                        anchors.centerIn: parent
                        text: root.muted ? "UNMUTE" : "MUTE"
                        color: muteButton.foreground
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize - 2
                        font.bold: true
                    }
                }
            }
            Text {
                visible: root.keyboardDriven
                text: "Esc or click outside to close"
                color: root.theme.textMuted
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
            }
        }
    }
}
