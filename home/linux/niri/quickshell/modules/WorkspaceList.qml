import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property var workspaces
    required property string screenName
    required property var theme
    signal focusWorkspace(int index)

    spacing: 4

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
        model: root.visibleWorkspaces

        delegate: Rectangle {
            id: workspace

            required property var modelData

            implicitWidth: 28
            implicitHeight: 28
            radius: 5
            color: modelData.is_urgent ? root.theme.danger : (modelData.is_focused ? root.theme.accent : (workspaceMouse.pressed ? root.theme.surfacePressed : (workspaceMouse.containsMouse ? root.theme.surfaceHover : root.theme.surfaceSelected)))
            border.color: workspaceMouse.containsMouse ? root.theme.focusRing : (modelData.is_urgent ? root.theme.danger : "transparent")
            border.width: 1
            opacity: workspaceMouse.pressed ? 0.75 : 1
            Accessible.role: Accessible.Button
            Accessible.name: "Workspace " + modelData.idx + (modelData.is_focused ? ", focused" : "") + (modelData.is_urgent ? ", urgent" : "")

            Text {
                anchors.centerIn: parent
                text: modelData.idx
                color: modelData.is_focused || modelData.is_urgent ? root.theme.textOnAccent : root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
            }

            MouseArea {
                id: workspaceMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.focusWorkspace(modelData.idx)
            }

            BarTooltip {
                anchorItem: workspace
                theme: root.theme
                text: "Workspace " + modelData.idx + (modelData.is_urgent ? " · urgent" : "")
                show: workspaceMouse.containsMouse
            }
        }
    }
}
