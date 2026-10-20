import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property var workspaces
    required property string screenName
    required property var theme
    signal focusWorkspace(int index)

    spacing: Math.round(theme.fontSize / 3) // 4

    readonly property var visibleWorkspaces: {
        const visible = workspaces.filter(workspace => workspace.output === screenName);
        if (visible.length > 0)
            return visible.sort((a, b) => a.idx - b.idx);

        return Array.from({
            length: 9
        }, (_, index) => ({
                    idx: index + 1,
                    is_focused: false,
                    is_urgent: false
                }));
    }

    Repeater {
        // A count model keeps delegates alive when only workspace state changes.
        model: root.visibleWorkspaces.length

        // Stamped tabs. Focused: accent plate printed off-register behind an
        // ink-keylined chip. Occupied: ink numeral on paper. Empty: muted
        // numeral, no chip — so which workspaces hold windows reads at a glance.
        delegate: Item {
            id: workspace

            required property int index
            readonly property var modelData: root.visibleWorkspaces[index]
            readonly property bool occupied: modelData.active_window_id !== undefined && modelData.active_window_id !== null
            readonly property bool lit: modelData.is_focused || modelData.is_urgent

            implicitWidth: root.theme.controlSize
            implicitHeight: root.theme.controlSize
            Accessible.role: Accessible.Button
            Accessible.name: "Workspace " + modelData.idx + (modelData.is_focused ? ", focused" : "") + (modelData.is_urgent ? ", urgent" : "") + (workspace.occupied ? "" : ", empty")

            // Focus moving here stamps the tab in through the press dither.
            onLitChanged: {
                if (!lit || !root.theme.animationsEnabled)
                    return;
                stamp.progress = 0;
                stampPrint.restart();
            }

            NumberAnimation {
                id: stampPrint
                target: stamp
                property: "progress"
                to: 1
                duration: 160
                easing.type: Easing.OutCubic
            }

            Item {
                id: stamp

                property real progress: 1

                anchors.fill: parent
                layer.enabled: stampPrint.running
                layer.smooth: false
                layer.effect: PrintEffect {
                    progress: stamp.progress
                }

                Rectangle {
                    visible: workspace.lit
                    x: root.theme.plateOffset
                    y: root.theme.plateOffset
                    width: chip.width
                    height: chip.height
                    color: modelData.is_urgent ? root.theme.danger : root.theme.plate
                }

                Rectangle {
                    id: chip

                    // Hover keylines an unlit tab in ink; a press drops it onto
                    // where its plate would print.
                    x: workspaceMouse.pressed && !workspace.lit ? root.theme.plateOffset : 0
                    y: x
                    width: parent.width - root.theme.plateOffset
                    height: parent.height - root.theme.plateOffset
                    radius: root.theme.radius
                    color: modelData.is_urgent ? root.theme.ink : root.theme.background
                    border.color: workspace.lit || workspaceMouse.containsMouse ? root.theme.ink : "transparent"
                    border.width: root.theme.ruleWidth

                    Text {
                        anchors.centerIn: parent
                        text: modelData.idx + (modelData.is_urgent ? "!" : "")
                        color: modelData.is_urgent ? root.theme.background : (workspace.lit || workspace.occupied ? root.theme.textPrimary : root.theme.textMuted)
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize
                        font.bold: workspace.lit
                    }
                }
            }

            MouseArea {
                id: workspaceMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressAndHold: wsTip.pinned = true
                onClicked: root.focusWorkspace(modelData.idx)
            }

            BarTooltip {
                id: wsTip

                anchorItem: workspace
                theme: root.theme
                text: "Workspace " + modelData.idx + (modelData.is_urgent ? " · urgent" : "")
                show: workspaceMouse.containsMouse
            }
        }
    }
}
