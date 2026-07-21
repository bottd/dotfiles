import QtQuick
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root

    required property Item anchorItem
    required property var theme
    required property string text
    property bool show: false
    property bool shown: false

    visible: root.shown && root.text !== ""
    grabFocus: false
    color: "transparent"
    implicitWidth: Math.min(label.implicitWidth + 16, 360)
    implicitHeight: Math.min(label.implicitHeight + 12, 180)

    anchor {
        window: root.anchorItem.QsWindow.window
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.Slide | PopupAdjustment.ResizeY

        onAnchoring: {
            const position = root.anchorItem.QsWindow.contentItem.mapFromItem(root.anchorItem, root.anchorItem.width / 2 - root.width / 2, -root.height - 6);
            anchor.rect.x = position.x;
            anchor.rect.y = position.y;
        }
    }

    onShowChanged: {
        if (root.show)
            showTimer.restart();
        else {
            showTimer.stop();
            root.shown = false;
        }
    }

    Timer {
        id: showTimer

        interval: 500
        onTriggered: root.shown = root.show
    }

    Rectangle {
        anchors.fill: parent
        radius: 5
        color: root.theme.surface
        border.color: root.theme.border
        border.width: 1
        clip: true

        Text {
            id: label

            anchors.centerIn: parent
            width: parent.width - 16
            height: Math.min(implicitHeight, parent.height - 12)
            text: root.text
            color: root.theme.textPrimary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSize - 1
            wrapMode: Text.Wrap
            maximumLineCount: 8
            elide: Text.ElideRight
        }
    }
}
