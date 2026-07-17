import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root

    required property var parentWindow
    required property var theme
    required property bool open
    signal dismissed

    property string query: ""
    property int selectedIndex: 0
    property var applicationIndex: DesktopEntries.applications.values
    property var filteredApplications: {
        const needle = root.query.trim().toLowerCase();
        return root.applicationIndex.filter(entry => {
            if (needle === "")
                return true;

            return entry.name.toLowerCase().includes(needle) || entry.genericName.toLowerCase().includes(needle) || entry.comment.toLowerCase().includes(needle) || entry.keywords.some(keyword => keyword.toLowerCase().includes(needle));
        });
    }

    anchor.window: root.parentWindow
    anchor.rect.x: (root.parentWindow.width - width) / 2
    anchor.rect.y: -height - 16
    width: 520
    height: 380
    visible: root.open
    grabFocus: true

    onVisibleChanged: {
        if (!visible && root.open)
            root.dismissed();
    }

    onOpenChanged: {
        if (open) {
            root.query = "";
            root.selectedIndex = 0;
            search.text = "";
            search.forceActiveFocus();
        }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            root.applicationIndex = DesktopEntries.applications.values;
        }
    }

    function launchSelected() {
        const entry = root.filteredApplications[root.selectedIndex];
        if (entry) {
            entry.execute();
            root.dismissed();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: root.theme.base00
        border.color: root.theme.base02
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            TextField {
                id: search

                Layout.fillWidth: true
                placeholderText: "Launch an application"
                text: root.query
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

                onTextChanged: {
                    root.query = text;
                    root.selectedIndex = 0;
                }
                Keys.onReturnPressed: root.launchSelected()
                Keys.onEscapePressed: root.dismissed()
                Keys.onDownPressed: {
                    root.selectedIndex = Math.min(root.selectedIndex + 1, root.filteredApplications.length - 1);
                    results.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                }
                Keys.onUpPressed: {
                    root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                    results.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                }
            }

            ListView {
                id: results

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 3
                model: root.filteredApplications

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: results.width
                    height: 38
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
    }
}
