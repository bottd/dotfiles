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
                    is_focused: false
                }));
    }

    Repeater {
        model: root.visibleWorkspaces

        delegate: Rectangle {
            required property var modelData

            implicitWidth: 22
            implicitHeight: 22
            radius: 5
            color: modelData.is_focused ? root.theme.base0D : root.theme.base02

            Text {
                anchors.centerIn: parent
                text: modelData.idx
                color: modelData.is_focused ? root.theme.base00 : root.theme.base05
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.focusWorkspace(modelData.idx)
            }
        }
    }
}
