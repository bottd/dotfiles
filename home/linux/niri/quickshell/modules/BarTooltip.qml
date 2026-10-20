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
    // Touch produces no hover, so on the pocket touchscreen a hover-only tooltip
    // is unreachable — and for tray items this text is the only place the item's
    // name appears at all. Call sites pin it from a long press.
    property bool pinned: false

    visible: (root.shown || root.pinned) && root.text !== ""
    grabFocus: false
    color: "transparent"
    readonly property int padX: Math.round(theme.fontSize * 0.67) // 8
    readonly property int padY: Math.round(theme.fontSize / 2) // 6
    implicitWidth: Math.min(label.implicitWidth + padX * 2, theme.fontSize * 30)
    implicitHeight: Math.min(label.implicitHeight + padY * 2, theme.fontSize * 15)

    anchor {
        window: root.anchorItem.QsWindow.window
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.Slide | PopupAdjustment.ResizeY

        onAnchoring: {
            const position = root.anchorItem.QsWindow.contentItem.mapFromItem(root.anchorItem, root.anchorItem.width / 2 - root.width / 2, -root.height - root.padY);
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

    Timer {
        running: root.pinned
        interval: 4000
        onTriggered: root.pinned = false
    }

    onVisibleChanged: {
        if (!visible || !root.theme.animationsEnabled)
            return;
        tag.progress = 0;
        tagPrint.restart();
    }

    NumberAnimation {
        id: tagPrint
        target: tag
        property: "progress"
        to: 1
        duration: 160
        easing.type: Easing.OutCubic
    }

    Rectangle {
        id: tag

        // Caption tags print in like the panels; they vanish without a lift.
        property real progress: 1

        anchors.fill: parent
        layer.enabled: tagPrint.running
        layer.smooth: false
        layer.effect: PrintEffect {
            progress: tag.progress
        }
        radius: root.theme.radius
        // Reversed out: paper type on an ink block, like a printed caption tag.
        color: root.theme.ink
        clip: true

        Text {
            id: label

            anchors.centerIn: parent
            width: parent.width - root.padX * 2
            height: Math.min(implicitHeight, parent.height - root.padY * 2)
            text: root.text
            textFormat: Text.PlainText
            color: root.theme.background
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSize - 1
            wrapMode: Text.Wrap
            maximumLineCount: 8
            elide: Text.ElideRight
        }
    }
}
