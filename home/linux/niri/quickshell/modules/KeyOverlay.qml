import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QMLTermWidget 2.0

PanelWindow {
    id: root

    required property var theme
    required property bool open
    required property string mode
    required property date now
    property bool presented: false
    readonly property real revealedHeight: Math.max(0, root.height - drawer.y)
    property var path: []
    property int selectedIndex: 0
    property bool journalStarted: false
    property string journalDate: ""
    property var confirmationItem: null
    readonly property color dangerColor: root.theme.danger || root.theme.accent
    readonly property alias journalFocused: journalTerminal.activeFocus
    readonly property var applicationIndex: DesktopEntries.applications.values
    signal dismissed
    signal modeRequested(string mode)

    readonly property var menu: [
        {
            key: "p",
            label: "Power",
            items: [
                {
                    key: "s",
                    label: "Sleep",
                    command: ["systemctl", "suspend"]
                },
                {
                    key: "r",
                    label: "Reboot",
                    description: "Restarts the system immediately",
                    destructive: true,
                    command: ["systemctl", "reboot"]
                },
                {
                    key: "o",
                    label: "Power off",
                    description: "Shuts down the system immediately",
                    destructive: true,
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
            label: "Apps",
            items: [
                {
                    key: "d",
                    label: "Equibop",
                    application: "Discord"
                },
                {
                    key: "s",
                    label: "Steam",
                    application: "Steam"
                },
                {
                    key: "b",
                    label: "Glide",
                    application: "Glide"
                }
            ]
        },
        {
            key: "m",
            label: "Meta",
            items: [
                {
                    key: "a",
                    label: "Airplane mode",
                    description: "Toggle all radios",
                    command: ["sh", "-c", "if LC_ALL=C rfkill -n -o SOFT | grep -q unblocked; then rfkill block all; else rfkill unblock all; fi"]
                }
            ]
        },
        {
            key: "s",
            label: "Screenshot",
            screenshot: true
        },
        {
            key: "d",
            targetMode: "launcher"
        }
    ]

    readonly property var activeItems: root.path.length === 0 ? root.menu : root.path[root.path.length - 1].items
    readonly property var commonApplications: ["Glide", "Ghostty", "Spotify", "Discord"].map(root.findApplication).filter(entry => entry)
    readonly property var recentApplications: recentState.apps.map(id => root.applicationIndex.find(entry => entry.id === id)).filter(entry => entry && !root.commonApplications.some(common => common.id === entry.id))
    readonly property date monthStart: new Date(root.now.getFullYear(), root.now.getMonth(), 1)
    readonly property int leadingDays: (root.monthStart.getDay() + 6) % 7
    readonly property int daysInMonth: new Date(root.now.getFullYear(), root.now.getMonth() + 1, 0).getDate()
    readonly property var filteredApplications: {
        const needle = search.text.trim().toLowerCase();
        if (needle === "") {
            return root.applicationIndex.slice().sort((a, b) => {
                const recentA = root.applicationRecency(a.id);
                const recentB = root.applicationRecency(b.id);
                if (recentA !== recentB)
                    return recentA - recentB;
                return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
            });
        }

        return root.applicationIndex.map((entry, index) => ({
                    entry: entry,
                    index: index,
                    score: root.applicationScore(needle, entry),
                    recent: root.applicationRecency(entry.id)
                })).filter(candidate => candidate.score > Number.NEGATIVE_INFINITY).sort((a, b) => b.score - a.score || a.recent - b.recent || a.entry.name.toLowerCase().localeCompare(b.entry.name.toLowerCase()) || a.index - b.index).map(candidate => candidate.entry);
    }

    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Math.min(360, root.screen.height * 0.45)
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
        return Math.max(root.fuzzyScore(needle, entry.name), root.fuzzyScore(needle, entry.genericName) - 10, root.fuzzyScore(needle, (entry.keywords || []).join(" ")) - 15, root.fuzzyScore(needle, entry.comment) - 25);
    }

    function applicationRecency(id) {
        const index = recentState.apps.indexOf(id);
        return index < 0 ? 1000000 : index;
    }

    function applicationSubtitle(entry) {
        const needle = search.text.trim().toLowerCase();
        const genericName = entry.genericName || "";
        const comment = entry.comment || "";
        let detail = genericName && genericName.toLowerCase() !== entry.name.toLowerCase() ? genericName : comment;

        if (needle !== "") {
            if (genericName.toLowerCase().includes(needle))
                detail = genericName;
            else {
                const keyword = (entry.keywords || []).find(value => (value || "").toLowerCase().includes(needle));
                if (keyword)
                    detail = keyword;
                else if (comment.toLowerCase().includes(needle))
                    detail = comment;
            }
        }

        if (root.applicationRecency(entry.id) < 1000000)
            return detail ? "Recent  ·  " + detail : "Recent";
        return detail;
    }

    function findApplication(name) {
        return root.applicationIndex.find(entry => entry.name.toLowerCase() === name.toLowerCase());
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

    function goBack() {
        root.clearDangerConfirmation();
        if (root.path.length === 0) {
            root.dismissed();
            return;
        }

        root.path = root.path.slice(0, -1);
    }

    function clearDangerConfirmation() {
        dangerConfirmationTimer.stop();
        root.confirmationItem = null;
    }

    function activate(item) {
        if (item.destructive) {
            if (root.confirmationItem !== item) {
                root.confirmationItem = item;
                dangerConfirmationTimer.restart();
                return;
            }
            root.clearDangerConfirmation();
        } else {
            root.clearDangerConfirmation();
        }

        if (item.items) {
            root.path = root.path.concat([item]);
            return;
        }

        if (item.targetMode) {
            root.modeRequested(item.targetMode);
            return;
        }

        if (item.application) {
            const entry = root.findApplication(item.application);
            if (entry)
                root.launchApplication(entry);
            return;
        }

        if (item.screenshot) {
            root.dismissed();
            screenshotTimer.restart();
            return;
        }

        if (item.command)
            Quickshell.execDetached(item.command);
        root.dismissed();
    }

    function launchSelected() {
        const entry = root.filteredApplications[root.selectedIndex];
        if (!entry)
            return;

        root.launchApplication(entry);
    }

    function launchApplication(entry) {
        recentState.apps = [entry.id].concat(recentState.apps.filter(id => id !== entry.id)).slice(0, 5);
        recentFile.writeAdapter();
        Quickshell.execDetached(root.theme.launcherCommand.concat([entry.id]));
        root.dismissed();
    }

    function focusJournal() {
        if (!root.journalStarted) {
            root.journalStarted = true;
            root.journalDate = Qt.formatDate(new Date(), "yyyy-MM-dd");
            journalStart.restart();
        }
        journalTerminal.forceActiveFocus();
    }

    function isOverlayKey(event) {
        return event.key === Qt.Key_F13 || event.key === Qt.Key_Tools;
    }

    function handleCommandKey(event) {
        if (event.isAutoRepeat) {
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) {
            root.goBack();
            event.accepted = true;
            return;
        }

        const key = event.text;
        if (root.path.length === 0 && key.toLowerCase() === "j") {
            root.focusJournal();
            event.accepted = true;
            return;
        }
        const item = root.activeItems.find(candidate => candidate.key === key.toLowerCase());
        if (item) {
            root.activate(item);
            event.accepted = true;
        }
    }

    onOpenChanged: {
        if (root.open) {
            screenshotTimer.stop();
            root.clearDangerConfirmation();
            root.presented = true;
            root.path = [];
            root.selectedIndex = 0;
            if (root.mode === "launcher")
                search.text = "";
            drawer.y = root.theme.animationsEnabled ? root.height : 0;
            Qt.callLater(function () {
                if (root.open) {
                    root.moveDrawer(0, false);
                    root.focusCurrentMode();
                }
            });
        } else if (root.presented) {
            root.clearDangerConfirmation();
            if (journalStart.running) {
                journalStart.stop();
                root.journalStarted = false;
                root.journalDate = "";
            }
            root.moveDrawer(root.height, true);
        }
    }

    onModeChanged: {
        root.clearDangerConfirmation();
        root.path = [];
        root.selectedIndex = 0;
        if (root.mode === "launcher") {
            search.text = "";
        }
        if (root.open) {
            Qt.callLater(function () {
                if (root.open)
                    root.focusCurrentMode();
            });
        }
    }

    Component.onCompleted: drawer.y = root.height

    FileView {
        id: recentFile

        path: Quickshell.statePath("recent-apps.json")
        blockLoading: true
        printErrors: false

        JsonAdapter {
            id: recentState

            property var apps: []
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

    Timer {
        id: screenshotTimer

        interval: 200
        onTriggered: Quickshell.execDetached(["niri", "msg", "action", "screenshot"])
    }

    Timer {
        id: dangerConfirmationTimer

        interval: 3000
        onTriggered: root.confirmationItem = null
    }

    FocusScope {
        anchors.fill: parent
        focus: root.open
        Keys.onPressed: function (event) {
            if (root.isOverlayKey(event)) {
                event.accepted = true;
                return;
            }
            if (root.mode === "commands" && !root.journalFocused)
                root.handleCommandKey(event);
        }
        Keys.onReleased: function (event) {
            if (root.isOverlayKey(event)) {
                root.dismissed();
                event.accepted = true;
            }
        }

        Rectangle {
            id: drawer

            width: parent.width
            height: parent.height
            color: root.theme.background

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 2
                color: root.theme.accent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    RowLayout {
                        anchors.fill: parent
                        visible: root.mode === "commands" && root.path.length === 0
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1.15
                            spacing: 6

                            Text {
                                text: "APPS"
                                color: root.theme.accent
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize
                                font.bold: true
                            }

                            Text {
                                text: "COMMON"
                                color: root.theme.textMuted
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize - 2
                            }

                            Repeater {
                                model: root.commonApplications

                                delegate: Rectangle {
                                    required property var modelData

                                    Layout.fillWidth: true
                                    implicitHeight: 30
                                    radius: 4
                                    color: commonMouse.containsMouse ? root.theme.surfaceHover : root.theme.surface

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 8

                                        IconImage {
                                            implicitWidth: 18
                                            implicitHeight: 18
                                            source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            elide: Text.ElideRight
                                            color: root.theme.textPrimary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize - 1
                                        }
                                    }

                                    MouseArea {
                                        id: commonMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: root.launchApplication(modelData)
                                    }
                                }
                            }

                            Text {
                                visible: root.recentApplications.length > 0 || recentState.apps.length === 0
                                text: "RECENT"
                                color: root.theme.textMuted
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize - 2
                            }

                            Repeater {
                                model: root.recentApplications.slice(0, 3)

                                delegate: Rectangle {
                                    required property var modelData

                                    Layout.fillWidth: true
                                    implicitHeight: 28
                                    radius: 4
                                    color: recentMouse.containsMouse ? root.theme.surfaceHover : "transparent"

                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        verticalAlignment: Text.AlignVCenter
                                        text: modelData.name
                                        elide: Text.ElideRight
                                        color: root.theme.textPrimary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSize - 1
                                    }

                                    MouseArea {
                                        id: recentMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: root.launchApplication(modelData)
                                    }
                                }
                            }

                            Text {
                                visible: recentState.apps.length === 0
                                text: "No drawer launches yet"
                                color: root.theme.textMuted
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize - 2
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            Text {
                                text: "d  ALL APPLICATIONS"
                                color: root.theme.accent
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize - 1

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.modeRequested("launcher")
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            implicitWidth: 1
                            color: root.theme.accent
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1.15
                            spacing: 6

                            Text {
                                text: "HOTKEYS"
                                color: root.theme.accent
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize
                                font.bold: true
                            }

                            Repeater {
                                model: root.menu.filter(item => item.items || item.screenshot)

                                delegate: Rectangle {
                                    required property var modelData

                                    Layout.fillWidth: true
                                    implicitHeight: 34
                                    radius: 4
                                    color: hotkeyMouse.containsMouse ? root.theme.surfaceHover : root.theme.surface

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8

                                        Text {
                                            text: modelData.key
                                            color: root.theme.accent
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize
                                            font.bold: true
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.label
                                            color: root.theme.textPrimary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize - 1
                                        }
                                    }

                                    MouseArea {
                                        id: hotkeyMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: root.activate(modelData)
                                    }
                                }
                            }

                            Text {
                                text: "SHORTCUTS"
                                color: root.theme.textMuted
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize - 2
                            }

                            Text {
                                text: "a quick apps   d all apps   j journal"
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize - 2
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            implicitWidth: 1
                            color: root.theme.accent
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: root.journalFocused ? 2 : 1.5
                            spacing: 8

                            Text {
                                text: "DAILY JOURNAL"
                                color: root.theme.accent
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: root.theme.background
                                border.color: root.journalFocused ? root.theme.focusRing : root.theme.border
                                border.width: 1
                                clip: true

                                QMLTermWidget {
                                    id: journalTerminal

                                    anchors.fill: parent
                                    anchors.margins: 4
                                    visible: root.presented
                                    font.family: root.theme.fontFamily
                                    font.pointSize: root.theme.fontSize
                                    colorScheme: "Stylix"
                                    antialiasText: true
                                    blinkingCursor: false
                                    enableBold: true
                                    enableItalic: true
                                    fullCursorHeight: true
                                    useFBORendering: false
                                    session: QMLTermSession {
                                        id: journalSession

                                        shellProgram: root.theme.journalProgram
                                        onFinished: {
                                            root.journalStarted = false;
                                            root.journalDate = "";
                                            if (root.open)
                                                root.focusCurrentMode();
                                        }
                                    }
                                    Keys.priority: Keys.BeforeItem
                                    Keys.onPressed: function (event) {
                                        if (root.isOverlayKey(event))
                                            event.accepted = true;
                                    }
                                    Keys.onReleased: function (event) {
                                        if (root.isOverlayKey(event)) {
                                            root.dismissed();
                                            event.accepted = true;
                                        }
                                    }
                                }

                                Timer {
                                    id: journalStart

                                    interval: 250
                                    onTriggered: {
                                        journalTerminal.lineSpacing = 1;
                                        journalTerminal.lineSpacing = 0;
                                        journalSession.startShellProgram();
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    visible: !root.journalFocused
                                    onClicked: root.focusJournal()

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        width: focusHint.width + 12
                                        height: focusHint.height + 8
                                        color: root.theme.surface
                                        border.color: root.theme.focusRing
                                        border.width: 1

                                        Text {
                                            id: focusHint

                                            anchors.centerIn: parent
                                            text: "j  FOCUS"
                                            color: root.theme.accent
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize - 2
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (root.journalDate || Qt.formatDate(root.now, "yyyy-MM-dd")) + ".norg" + (root.journalFocused ? "  /  SUPER hides" : "  /  j focuses")
                                elide: Text.ElideRight
                                color: root.theme.textMuted
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize - 2
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            implicitWidth: 1
                            color: root.theme.accent
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1.4

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 6

                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: Qt.formatDate(root.now, "MMMM yyyy").toUpperCase()
                                    color: root.theme.accent
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize
                                    font.bold: true
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 7
                                    columnSpacing: 4
                                    rowSpacing: 3

                                    Repeater {
                                        model: ["M", "T", "W", "T", "F", "S", "S"]

                                        delegate: Text {
                                            required property string modelData

                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignHCenter
                                            text: modelData
                                            color: root.theme.textMuted
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize - 2
                                        }
                                    }

                                    Repeater {
                                        model: 42

                                        delegate: Rectangle {
                                            required property int index
                                            readonly property int calendarDay: index - root.leadingDays + 1
                                            readonly property var day: calendarDay > 0 && calendarDay <= root.daysInMonth ? calendarDay : ""
                                            readonly property bool today: day === root.now.getDate()

                                            Layout.fillWidth: true
                                            implicitHeight: 27
                                            radius: 4
                                            color: today ? root.theme.accent : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: day
                                                color: parent.today ? root.theme.textOnAccent : root.theme.textPrimary
                                                font.family: root.theme.fontFamily
                                                font.pixelSize: root.theme.fontSize - 1
                                                font.bold: parent.today
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }

                    Flow {
                        anchors.fill: parent
                        visible: root.mode === "commands" && root.path.length > 0
                        spacing: 8

                        Repeater {
                            model: root.path.length > 0 ? root.activeItems : []

                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool destructive: !!modelData.destructive
                                readonly property bool confirming: root.confirmationItem === modelData

                                width: Math.max(destructive ? 240 : 150, commandLabel.implicitWidth + commandKey.implicitWidth + 42)
                                height: 56
                                radius: 6
                                color: confirming ? root.dangerColor : (commandMouse.containsMouse ? root.theme.surfaceHover : root.theme.surface)
                                border.color: destructive ? root.dangerColor : (commandMouse.containsMouse ? root.theme.focusRing : root.theme.border)
                                border.width: 1
                                opacity: commandMouse.pressed ? 0.75 : 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    Text {
                                        id: commandKey

                                        text: modelData.key
                                        color: confirming ? root.theme.textOnAccent : (destructive ? root.dangerColor : root.theme.accent)
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
                                            color: confirming ? root.theme.textOnAccent : (destructive ? root.dangerColor : root.theme.textPrimary)
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: confirming ? "Press " + modelData.key + " again to confirm" : (modelData.description || "")
                                            elide: Text.ElideRight
                                            color: confirming ? root.theme.textOnAccent : root.theme.textMuted
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSize - 2
                                        }
                                    }
                                }

                                MouseArea {
                                    id: commandMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.activate(modelData)
                                }
                            }
                        }
                    }

                    ListView {
                        id: results

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(parent.width, 840)
                        visible: root.mode === "launcher"
                        clip: true
                        spacing: 3
                        model: root.filteredApplications
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Rectangle {
                            id: resultRow

                            required property var modelData
                            required property int index

                            width: results.width
                            height: 48
                            radius: 5
                            color: index === root.selectedIndex ? root.theme.surfaceSelected : (resultMouse.containsMouse ? root.theme.surfaceHover : "transparent")
                            border.color: index === root.selectedIndex ? root.theme.focusRing : "transparent"
                            border.width: 1

                            IconImage {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 22
                                implicitHeight: 22
                                source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                            }

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.leftMargin: 40
                                anchors.right: parent.right
                                anchors.rightMargin: 18
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    elide: Text.ElideRight
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: root.applicationSubtitle(modelData)
                                    elide: Text.ElideRight
                                    color: root.theme.textMuted
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize - 2
                                }
                            }

                            MouseArea {
                                id: resultMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.launchApplication(modelData)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.filteredApplications.length === 0
                            text: "No applications found"
                            color: root.theme.textMuted
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSize
                        }
                    }
                }

                TextField {
                    id: search

                    Layout.fillWidth: true
                    Layout.maximumWidth: 840
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.mode === "launcher"
                    placeholderText: "Search applications"
                    selectByMouse: true
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                    color: root.theme.textPrimary
                    placeholderTextColor: root.theme.textMuted
                    background: Rectangle {
                        radius: 6
                        color: root.theme.surface
                        border.color: search.activeFocus ? root.theme.focusRing : root.theme.border
                        border.width: 1
                    }
                    onTextChanged: {
                        root.selectedIndex = 0;
                        results.positionViewAtBeginning();
                    }
                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Escape) {
                            root.dismissed();
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
