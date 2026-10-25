import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QMLTermWidget 2.0
import "tlds.js" as Tlds

PanelWindow {
    id: root

    required property var theme
    required property bool open
    required property string mode
    required property date now
    property bool presented: false
    property var path: []
    property int selectedIndex: 0
    property bool journalStarted: false
    property string journalDate: ""
    property var confirmationItem: null
    property double armedAt: 0
    readonly property var applicationIndex: DesktopEntries.applications.values
    readonly property var steamEntry: findApplication("Steam") || null
    signal dismissed
    signal modeRequested(string mode)
    signal shellActionRequested(string action, bool keyboard)
    property bool pointerActivation: false
    property var webSuggestions: []
    property int webGeneration: 0
    // The trimmed text suggestions were last asked for, so a trailing space
    // doesn't drop the answer in flight and ask again.
    property string webQuery: ""
    // Installed games from Aurelia, kept between opens so the list shows at
    // once while it refreshes.
    property var games: []
    property bool gamesLoading: false
    property bool gamesFailed: false
    // Rows from `network list`, kept between opens like the game library.
    property var networkItems: []
    property bool networkLoaded: false
    property bool networkFailed: false
    property bool networkScanning: false
    property bool networkRescanQueued: false
    property string networkMessage: ""
    property bool networkMessageOk: true
    property string networkPending: ""
    // A row waiting for a password or SIM PIN; the search field takes it.
    property var secretItem: null

    readonly property var menu: [
        {
            key: "d",
            label: "Applications",
            description: "Find and launch an application",
            targetMode: "launcher"
        },
        {
            key: "g",
            label: "Games",
            description: "Play an installed game",
            targetMode: "games"
        },
        {
            key: "j",
            label: "Daily journal",
            description: "Today's page and calendar",
            targetMode: "journal"
        },
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
                    command: ["systemd-run", "--user", "--collect", "--", "swaylock"]
                }
            ]
        },
        {
            key: "a",
            label: "Pinned apps",
            items: [
                {
                    key: "d",
                    label: "Equibop",
                    application: "Discord"
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
            label: "Connections",
            items: [
                {
                    key: "a",
                    label: "Airplane mode",
                    description: "Toggle all radios",
                    command: ["sh", "-c", "if LC_ALL=C rfkill -n -o SOFT | grep -q unblocked; then rfkill block all; else rfkill unblock all; fi"]
                },
                {
                    key: "v",
                    label: "VPN exit node",
                    description: "Toggle the Tailscale exit node",
                    shellAction: "vpn"
                },
                {
                    key: "n",
                    label: "Network",
                    description: "Ethernet, Wi-Fi and mobile broadband",
                    targetMode: "network"
                }
            ]
        },
        {
            key: "v",
            label: "Volume",
            description: "Arrows adjust · M mutes",
            shellAction: "volume"
        },
        {
            key: "b",
            label: "Brightness",
            description: "Arrows adjust",
            shellAction: "brightness"
        },
        {
            key: "s",
            label: "Screenshot",
            screenshot: true
        },
        {
            key: "w",
            label: "Web",
            description: "Open a URL or search " + theme.searchName,
            targetMode: "web"
        }
    ]
    readonly property var modeText: ({
            commands: {
                heading: "COMMANDS",
                searchName: "Search commands",
                placeholder: "Search commands · / to type",
                empty: "No matching commands · Esc clears the search"
            },
            launcher: {
                heading: "APPLICATIONS",
                searchName: "Search applications",
                placeholder: "Search applications",
                empty: "No matching applications · Esc clears the search"
            },
            games: {
                heading: "GAMES",
                searchName: "Search games",
                placeholder: "Search games",
                empty: gamesFailed && !games.length ? "Couldn't read the library · run games list in a terminal" : (gamesLoading && !games.length ? "Reading library…" : (games.length ? "No matching games · Esc clears the search" : "No installed games" + (steamEntry ? " · Ctrl+S opens Steam" : "")))
            },
            web: {
                heading: "WEB",
                searchName: "URL or " + theme.searchName + " search",
                placeholder: "URL or " + theme.searchName + " search",
                empty: "Type a URL or a search"
            },
            network: {
                heading: "NETWORK",
                searchName: secretItem ? secretItem.secret : "Filter networks",
                placeholder: secretItem ? secretItem.secret : "Filter networks · / to type",
                empty: networkFailed && !networkItems.length ? "NetworkManager isn't answering · try nmcli in a terminal" : (!networkLoaded ? "Reading connections…" : "No matching networks · Esc clears the search")
            },
            journal: {
                heading: "DAILY JOURNAL",
                searchName: "",
                placeholder: "",
                empty: ""
            }
        })
    readonly property var activeItems: path.length ? path[path.length - 1].items : menu
    // Each list is only computed in its own mode; the others would be rescored
    // on every keystroke for nothing.
    readonly property var filteredCommands: mode !== "commands" ? [] : activeItems.filter(item => (!item.application || findApplication(item.application)) && (item.targetMode !== "games" || theme.gamesListCommand.length) && (!search.text.trim() || fuzzyScore(search.text.trim().toLowerCase(), item.label + " " + (item.description || "")) > Number.NEGATIVE_INFINITY))
    readonly property var filteredApplications: {
        if (mode !== "launcher")
            return [];
        const needle = search.text.trim().toLowerCase();
        return applicationIndex.map(entry => ({
                    entry: entry,
                    score: needle ? applicationScore(needle, entry) : 0
                })).filter(item => item.score > Number.NEGATIVE_INFINITY).sort((a, b) => b.score - a.score || applicationRecency(a.entry.id) - applicationRecency(b.entry.id) || a.entry.name.localeCompare(b.entry.name)).map(item => item.entry);
    }
    readonly property var filteredGames: {
        if (mode !== "games")
            return [];
        const needle = search.text.trim().toLowerCase();
        return games.map(game => ({
                    game: game,
                    score: needle ? fuzzyScore(needle, game.label) : 0
                })).filter(item => item.score > Number.NEGATIVE_INFINITY).sort((a, b) => b.score - a.score || gameRecency(a.game.appId) - gameRecency(b.game.appId) || a.game.sortName.localeCompare(b.game.sortName)).map(item => item.game);
    }
    // The typed text always yields a row, so Enter works offline or before
    // the engine answers; its suggestions fill in below as they arrive.
    readonly property var webItems: {
        const query = search.text.trim();
        if (mode !== "web" || !query)
            return [];
        const address = webAddress(query);
        const items = address ? [addressItem(address)] : [];
        items.push(searchItem(query, "Search " + theme.searchName));
        // A suggestion that is itself an address opens the page, as typing it would.
        for (const suggestion of webSuggestions) {
            if (suggestion.toLowerCase() === query.toLowerCase())
                continue;
            const suggested = webAddress(suggestion);
            items.push(suggested ? addressItem(suggested) : searchItem(suggestion, theme.searchName + " suggestion"));
        }
        return items;
    }
    // While a secret is being typed the field holds it, so it never filters.
    readonly property var filteredNetwork: {
        if (mode !== "network")
            return [];
        const items = networkItems.concat(theme.networkEditorCommand.length ? [
            {
                id: "editor",
                key: "⚙",
                label: "Connection editor",
                description: "Hidden, enterprise, VPN and APN settings",
                editor: true
            }
        ] : []);
        const needle = secretItem ? "" : search.text.trim().toLowerCase();
        return needle ? items.filter(item => fuzzyScore(needle, item.label + " " + (item.description || "")) > Number.NEGATIVE_INFINITY) : items;
    }
    readonly property var visibleItems: mode === "launcher" ? filteredApplications : (mode === "web" ? webItems : (mode === "games" ? filteredGames : (mode === "network" ? filteredNetwork : filteredCommands)))
    readonly property date monthStart: new Date(now.getFullYear(), now.getMonth(), 1)
    readonly property int leadingDays: (monthStart.getDay() + 6) % 7
    readonly property int daysInMonth: new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate()

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: presented
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "drake-command-panel"

    function fuzzyScore(needle, value) {
        const text = (value || "").toLowerCase();
        let score = 0, previous = -1, first = -1;
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
        return Math.max(fuzzyScore(needle, entry.name), fuzzyScore(needle, entry.genericName) - 10, fuzzyScore(needle, (entry.keywords || []).join(" ")) - 15, fuzzyScore(needle, entry.comment) - 25);
    }
    function applicationRecency(id) {
        const index = recentState.apps.indexOf(id);
        return index < 0 ? 1000000 : index;
    }
    function gameRecency(appId) {
        const index = recentState.games.indexOf(appId);
        return index < 0 ? 1000000 : index;
    }
    function refreshGames() {
        if (!theme.gamesListCommand.length || gamesProcess.running)
            return;
        gamesLoading = true;
        gamesFailed = false;
        gamesProcess.running = true;
    }
    function parseGames(text) {
        try {
            const library = JSON.parse(text);
            if (!Array.isArray(library))
                throw new Error("not a list");
            // Keep the highlight on the game it was on, not the index: a
            // refresh that adds or drops a title must not retarget Enter.
            const selected = root.mode === "games" ? filteredGames[selectedIndex] : null;
            games = library.map(game => {
                const minutes = game.playtime_forever_minutes || 0;
                const notes = [];
                if (minutes >= 60)
                    notes.push((minutes / 60).toFixed(minutes < 600 ? 1 : 0) + " h played");
                if (game.is_family_shared)
                    notes.push("family shared");
                return {
                    label: game.name,
                    sortName: game.name.replace(/^the\s+/i, ""),
                    description: notes.join(" · "),
                    appId: game.app_id,
                    icon: game.icon || ""
                };
            });
            if (selected)
                selectedIndex = Math.max(0, filteredGames.findIndex(game => game.appId === selected.appId));
        } catch (error) {
            gamesFailed = true;
        }
        gamesLoading = false;
    }
    // The theme icon Steam writes for a desktop shortcut is sharpest; its
    // library cache has a 32px icon for every installed game.
    function gameIcon(game) {
        return Quickshell.iconPath("steam_icon_" + game.appId, true) || (game.icon ? "file://" + game.icon : Qt.resolvedUrl("application.svg"));
    }
    // `games play` notifies, then blocks on `aurelia play` until the game
    // exits; the scope keeps it out of quickshell.service. Through Steam
    // bridges to the host client so Steamworks multiplayer works.
    function launchGame(game, throughSteam) {
        if (!open)
            return;
        recentState.games = [game.appId].concat(recentState.games.filter(id => id !== game.appId)).slice(0, 8);
        recentFile.writeAdapter();
        Quickshell.execDetached(theme.gameCommand.concat([game.label, String(game.appId)], throughSteam ? ["--steam"] : []));
        dismissed();
    }
    function launchSteam() {
        if (steamEntry)
            launchApplication(steamEntry);
    }
    // Anything with a space is a search. A scheme is kept as typed. Loopback,
    // IPs, LAN names and a bare host:port get http:// (Glide's HTTPS-First
    // still upgrades when it can); a dotted host gets https:// only when its
    // last label is a real TLD, so flake.nix or node.js stay searches.
    function webAddress(query) {
        if (/\s/.test(query))
            return "";
        if (/^[a-z][a-z0-9+.-]*:\/\//i.test(query) || /^(about|view-source):/i.test(query))
            return query;
        if (/^(localhost|\d{1,3}(\.\d{1,3}){3}|\[[0-9a-f:.]+\]|[a-z0-9-]+(?=:\d))(:\d+)?([/?#].*)?$/i.test(query))
            return "http://" + query;
        const host = query.match(/^(?:[^\s.:/?#@\[\]]+\.)+([^\s.:/?#@\[\]]+)\.?(:\d+)?([/?#].*)?$/);
        if (!host)
            return "";
        const tld = host[1].toLowerCase();
        if (["local", "lan", "home", "internal", "localdomain"].includes(tld))
            return "http://" + query;
        return Tlds.tlds.has(tld) ? "https://" + query : "";
    }
    // Web rows carry their keycap glyph as `key`, like command rows do.
    function addressItem(address) {
        return {
            key: "↗",
            label: address.replace(/^https?:\/\//i, ""),
            description: "Open in Glide",
            url: address
        };
    }
    function searchItem(query, description) {
        return {
            key: "?",
            label: query,
            description: description,
            url: theme.searchUrl.replace("{searchTerms}", encodeURIComponent(query))
        };
    }
    function resetWeb() {
        suggestTimer.stop();
        webGeneration++;
        webSuggestions = [];
        webQuery = "";
    }
    // Only web mode's onTextChanged starts the timer, and leaving the mode or
    // closing stops it, so this only runs for live web text.
    function fetchSuggestions() {
        const query = search.text.trim();
        const generation = ++webGeneration;
        // Addresses never leave the machine: a pasted reset link or LAN URL
        // is not a search.
        if (!query || webAddress(query)) {
            webSuggestions = [];
            return;
        }
        const request = new XMLHttpRequest();
        request.onreadystatechange = () => {
            if (request.readyState !== XMLHttpRequest.DONE || generation !== root.webGeneration)
                return;
            let suggestions = [];
            try {
                const body = JSON.parse(request.responseText);
                if (Array.isArray(body[1]))
                    suggestions = body[1].filter(value => typeof value === "string").slice(0, 8);
            } catch (error) {}
            // Keep the highlight on the row it was on, not the index.
            const selected = root.webItems[root.selectedIndex];
            root.webSuggestions = suggestions;
            root.selectedIndex = Math.max(0, selected ? root.webItems.findIndex(item => item.url === selected.url) : 0);
        };
        request.open("GET", theme.suggestUrl.replace("{searchTerms}", encodeURIComponent(query)));
        request.send();
    }
    function openWeb(item) {
        if (!open)
            return;
        Quickshell.execDetached(theme.browserCommand.concat([item.url]));
        dismissed();
    }
    // A plain list first so the panel fills at once, then a real scan; a scan
    // asked for while a list is in flight runs after it.
    function refreshNetwork(rescan) {
        if (networkListProcess.running) {
            networkRescanQueued = networkRescanQueued || rescan;
            return;
        }
        networkScanning = rescan;
        networkListProcess.command = ["network", "list"].concat(rescan ? ["--rescan"] : []);
        networkListProcess.running = true;
    }
    function parseNetwork(text) {
        try {
            const items = JSON.parse(text);
            if (!Array.isArray(items))
                throw new Error("not a list");
            // Keep the highlight on the row it was on: a scan that adds or
            // drops a network must not retarget Enter.
            const selected = mode === "network" ? filteredNetwork[selectedIndex] : null;
            networkItems = items;
            networkFailed = false;
            if (selected)
                selectedIndex = Math.max(0, filteredNetwork.findIndex(item => item.id === selected.id));
        } catch (error) {
            networkFailed = true;
        }
        networkLoaded = true;
    }
    function activateNetwork(item) {
        if (!open || !item)
            return;
        if (item.editor) {
            Quickshell.execDetached(theme.networkEditorCommand);
            dismissed();
            return;
        }
        if (!item.args) {
            networkMessage = item.description || "";
            networkMessageOk = true;
            return;
        }
        if (item.secret) {
            secretItem = item;
            search.text = "";
            search.forceActiveFocus();
            return;
        }
        runNetwork(item, "");
    }
    function submitSecret() {
        const item = secretItem;
        const secret = search.text;
        if (!item || !secret)
            return;
        cancelSecret();
        runNetwork(item, secret);
    }
    function cancelSecret() {
        secretItem = null;
        search.text = "";
        focusKeys();
    }
    // The secret rides in the environment, which only this user can read,
    // and the script hands it to nmcli on stdin; argv is world-readable.
    function runNetwork(item, secret) {
        if (networkActionProcess.running) {
            networkMessage = "Still working on " + networkPending;
            networkMessageOk = false;
            return;
        }
        networkPending = item.label;
        networkMessage = "";
        networkActionProcess.environment = {
            NETWORK_SECRET: secret || null
        };
        networkActionProcess.command = ["network"].concat(item.args);
        networkActionProcess.running = true;
    }
    function clearDangerConfirmation() {
        dangerTimer.stop();
        confirmationItem = null;
    }
    function goBack() {
        if (confirmationItem) {
            clearDangerConfirmation();
            return;
        }
        if (path.length) {
            path = path.slice(0, -1);
            search.text = "";
            selectedIndex = 0;
        } else if (mode !== "commands")
            modeRequested("commands");
        else
            dismissed();
    }
    function activate(item) {
        if (!open || !item)
            return;
        const index = visibleItems.findIndex(candidate => candidate.key === item.key);
        if (index >= 0)
            selectedIndex = index;
        if (item.destructive) {
            if (!confirmationItem || confirmationItem.key !== item.key) {
                clearDangerConfirmation();
                confirmationItem = item;
                armedAt = Date.now();
                dangerTimer.restart();
                return;
            }
            // A second deliberate activation confirms: Enter/Y from the
            // keyboard, or a second tap on pocket's touchscreen. The same 350ms
            // guard as the key path stops a double-click from firing it.
            if (Date.now() - armedAt >= 350)
                runItem(item);
            return;
        }
        runItem(item);
    }
    function runItem(item) {
        clearDangerConfirmation();
        if (item.items) {
            path = path.concat([item]);
            search.text = "";
            selectedIndex = 0;
            focusCurrentMode();
            return;
        }
        if (item.targetMode) {
            modeRequested(item.targetMode);
            return;
        }
        if (item.shellAction)
            shellActionRequested(item.shellAction, !pointerActivation);
        else if (item.application) {
            const entry = findApplication(item.application);
            if (entry)
                launchApplication(entry);
            return;
        } else if (item.screenshot) {
            dismissed();
            screenshotTimer.restart();
            return;
        } else if (item.command)
            Quickshell.execDetached(item.command);
        dismissed();
    }
    function launchApplication(entry) {
        if (!open)
            return;
        recentState.apps = [entry.id].concat(recentState.apps.filter(id => id !== entry.id)).slice(0, 8);
        recentFile.writeAdapter();
        Quickshell.execDetached(theme.launcherCommand.concat([entry.id]));
        dismissed();
    }
    function launchSelected(alternate) {
        const item = visibleItems[selectedIndex];
        if (!item)
            return;
        if (mode === "launcher")
            launchApplication(item);
        else if (mode === "games")
            launchGame(item, !!alternate);
        else if (mode === "web")
            openWeb(item);
        else if (mode === "network")
            activateNetwork(item);
        else
            activate(item);
    }
    function focusCurrentMode() {
        if (mode === "launcher" || mode === "web" || mode === "games")
            search.forceActiveFocus();
        else if (mode === "journal") {
            if (!journalStarted) {
                journalStarted = true;
                journalDate = Qt.formatDateTime(new Date(), "yyyy-MM-dd");
                journalStart.restart();
            }
            journalTerminal.forceActiveFocus();
        } else
            focusKeys();
    }
    // keyScope is a FocusScope: forceActiveFocus() alone hands focus back to
    // whichever child last held it (the search field after any launcher use),
    // so the command letters would type into search instead of firing.
    function focusKeys() {
        search.focus = false;
        journalTerminal.focus = false;
        navigationFocus.forceActiveFocus();
    }
    function findApplication(name) {
        return applicationIndex.find(entry => entry.name.toLowerCase() === name.toLowerCase());
    }
    function isOverlayKey(event) {
        return event.key === Qt.Key_F13 || event.key === Qt.Key_Tools;
    }
    function handleKey(event, typing) {
        if (!open)
            return;
        if (event.modifiers & (Qt.MetaModifier | Qt.AltModifier)) {
            event.accepted = true;
            return;
        }
        if (isOverlayKey(event)) {
            event.accepted = true;
            return;
        }
        if (confirmationItem) {
            if (event.isAutoRepeat) {
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.text.toLowerCase() === "y") {
                if (Date.now() - armedAt >= 350)
                    runItem(confirmationItem);
                event.accepted = true;
                return;
            }
            clearDangerConfirmation();
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                return;
            }
        }
        if (secretItem) {
            if (event.key === Qt.Key_Escape) {
                if (!event.isAutoRepeat)
                    cancelSecret();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (!event.isAutoRepeat)
                    submitSecret();
                event.accepted = true;
            }
            return;
        }
        if (event.key === Qt.Key_Escape && search.text) {
            search.text = "";
            event.accepted = true;
        } else if (mode === "network" && (event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_R) {
            if (!event.isAutoRepeat)
                refreshNetwork(true);
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape || (event.key === Qt.Key_Backspace && !search.text)) {
            if (!event.isAutoRepeat)
                goBack();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_N || event.key === Qt.Key_P))) {
            const down = event.key === Qt.Key_Down || event.key === Qt.Key_N;
            selectedIndex = Math.max(0, Math.min(visibleItems.length - 1, selectedIndex + (down ? 1 : -1)));
            results.positionViewAtIndex(selectedIndex, ListView.Contain);
            if (!typing)
                focusKeys();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (!event.isAutoRepeat)
                launchSelected(event.modifiers & Qt.ShiftModifier);
            event.accepted = true;
        } else if (mode === "games" && (event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
            if (!event.isAutoRepeat)
                launchSteam();
            event.accepted = true;
        } else if (!typing && event.text === "/") {
            search.forceActiveFocus();
            event.accepted = true;
        } else if (!typing && !event.isAutoRepeat && mode === "commands") {
            const item = filteredCommands.find(item => item.key === event.text.toLowerCase());
            if (item) {
                activate(item);
                event.accepted = true;
            }
        }
    }

    onSelectedIndexChanged: {
        if (confirmationItem && (!visibleItems[selectedIndex] || visibleItems[selectedIndex].key !== confirmationItem.key))
            clearDangerConfirmation();
    }

    onOpenChanged: {
        clearDangerConfirmation();
        resetWeb();
        secretItem = null;
        networkMessage = "";
        if (open) {
            screenshotTimer.stop();
            presented = true;
            path = [];
            search.text = "";
            selectedIndex = 0;
            panel.printIn();
            if (mode === "games")
                refreshGames();
            if (mode === "network") {
                refreshNetwork(false);
                refreshNetwork(true);
            }
            Qt.callLater(() => {
                if (root.open)
                    root.focusCurrentMode();
            });
        } else {
            if (journalStart.running) {
                journalStart.stop();
                journalStarted = false;
            }
            panel.pressOut();
        }
    }
    onModeChanged: {
        clearDangerConfirmation();
        // A new mode is a fresh proof pulled over the same sheet.
        if (open)
            panel.printIn();
        resetWeb();
        secretItem = null;
        networkMessage = "";
        if (open && mode === "games")
            refreshGames();
        if (open && mode === "network") {
            refreshNetwork(false);
            refreshNetwork(true);
        }
        path = [];
        search.text = "";
        selectedIndex = 0;
        Qt.callLater(() => {
            if (root.open)
                root.focusCurrentMode();
        });
    }
    FileView {
        id: recentFile
        path: Quickshell.statePath("recent-apps.json")
        blockLoading: true
        printErrors: false
        JsonAdapter {
            id: recentState
            property var apps: []
            property var games: []
        }
    }
    Process {
        id: gamesProcess
        command: root.theme.gamesListCommand
        stdout: StdioCollector {
            onStreamFinished: root.parseGames(text)
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.gamesFailed = true;
                root.gamesLoading = false;
            }
        }
    }
    Process {
        id: networkListProcess
        stdout: StdioCollector {
            onStreamFinished: root.parseNetwork(text)
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.networkFailed = true;
                root.networkLoaded = true;
            }
            root.networkScanning = false;
            if (root.networkRescanQueued) {
                root.networkRescanQueued = false;
                root.refreshNetwork(true);
            }
        }
    }
    Process {
        id: networkActionProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    root.networkMessage = result.message || "";
                    root.networkMessageOk = !!result.ok;
                } catch (error) {
                    root.networkMessage = "network gave no answer";
                    root.networkMessageOk = false;
                }
            }
        }
        onStarted: networkActionProcess.environment = {
            NETWORK_SECRET: null
        }
        onExited: {
            root.networkPending = "";
            root.refreshNetwork(false);
            root.shellActionRequested("network-changed", false);
        }
    }
    // NetworkManager changes underneath an open panel (cable, roaming).
    Timer {
        interval: 5000
        repeat: true
        running: root.open && root.mode === "network"
        onTriggered: root.refreshNetwork(false)
    }
    // Leave compositor toggle binds and media keys available, including in nvim.
    Timer {
        id: pointerGuard
        interval: Qt.styleHints.mouseDoubleClickInterval
    }
    Timer {
        id: suggestTimer
        interval: 150
        onTriggered: root.fetchSuggestions()
    }
    Timer {
        id: screenshotTimer
        interval: 200
        onTriggered: Quickshell.execDetached(["niri", "msg", "action", "screenshot"])
    }
    Timer {
        id: dangerTimer
        interval: 3000
        onTriggered: root.clearDangerConfirmation()
    }
    Timer {
        id: journalStart
        interval: 100
        onTriggered: {
            if (root.open && root.mode === "journal")
                journalSession.startShellProgram();
            else
                root.journalStarted = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }
    FocusScope {
        id: keyScope
        anchors.fill: parent
        focus: root.open
        Item {
            id: navigationFocus
        }
        Keys.onPressed: event => {
            if (root.mode !== "journal")
                root.handleKey(event, false);
        }
        Keys.onReleased: event => {
            if (root.isOverlayKey(event)) {
                root.dismissed();
                event.accepted = true;
            }
        }

        PressPanel {
            id: panel
            theme: root.theme
            anchors.centerIn: parent
            onPressedOut: {
                if (!root.open)
                    root.presented = false;
            }
            width: Math.min(parent.width - root.theme.fontSize * 4, root.theme.fontSize * (root.mode === "journal" ? 90 : 62))
            height: Math.min(parent.height - root.theme.fontSize * 4, root.theme.fontSize * 44)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.fontSize * 1.5
                spacing: root.theme.fontSize

                RowLayout {
                    Layout.fillWidth: true
                    PressButton {
                        id: backButton
                        theme: root.theme
                        visible: root.path.length > 0 || root.mode !== "commands"
                        implicitWidth: root.theme.fontSize * 6
                        Accessible.name: "Back"
                        onClicked: root.goBack()
                        Text {
                            anchors.centerIn: parent
                            text: "BACK"
                            color: backButton.foreground
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSize
                            font.bold: true
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.path.length ? root.path.map(entry => entry.label).join(" / ").toUpperCase() : root.modeText[root.mode].heading
                        elide: Text.ElideRight
                        color: root.theme.ink
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.headingSize * 1.2
                        font.bold: true
                    }
                    // A cached list stays usable while it refreshes, so its
                    // freshness is said here rather than in the empty state.
                    Row {
                        visible: root.mode === "games" && root.games.length > 0 && (root.gamesLoading || root.gamesFailed)
                        spacing: Math.round(root.theme.fontSize / 2.4)
                        Accessible.role: Accessible.StaticText
                        Accessible.name: gamesStatus.text
                        Rectangle {
                            visible: root.gamesFailed
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(5, Math.round(root.theme.fontSize / 2.4))
                            height: width
                            color: root.theme.danger
                        }
                        Text {
                            id: gamesStatus
                            text: root.gamesFailed ? "LIBRARY NOT REFRESHED" : "REFRESHING…"
                            color: root.gamesFailed ? root.theme.danger : root.theme.textMuted
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSize - 2
                            font.bold: root.gamesFailed
                        }
                    }
                    Text {
                        readonly property bool failed: !root.networkPending && !root.networkScanning && !root.networkMessageOk
                        visible: root.mode === "network" && text !== ""
                        Layout.maximumWidth: root.theme.fontSize * 30
                        text: root.networkPending ? "CONNECTING " + root.networkPending.toUpperCase() + "…" : (root.networkScanning ? "SCANNING…" : root.networkMessage.toUpperCase())
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: failed ? root.theme.danger : root.theme.textMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize - 2
                        font.bold: failed
                        Accessible.role: Accessible.StaticText
                        Accessible.name: text
                    }
                    PressButton {
                        id: closeButton
                        theme: root.theme
                        implicitWidth: root.theme.fontSize * 7
                        Accessible.name: "Close panel"
                        onClicked: root.dismissed()
                        Text {
                            anchors.centerIn: parent
                            text: "CLOSE"
                            color: closeButton.foreground
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

                TextField {
                    id: search
                    Layout.fillWidth: true
                    visible: root.mode !== "journal"
                    placeholderText: root.modeText[root.mode].placeholder
                    Accessible.name: root.modeText[root.mode].searchName
                    echoMode: root.secretItem ? TextInput.Password : TextInput.Normal
                    inputMethodHints: root.secretItem ? Qt.ImhSensitiveData | Qt.ImhNoPredictiveText : Qt.ImhNone
                    selectByMouse: true
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                    color: root.theme.ink
                    placeholderTextColor: root.theme.textMuted
                    selectionColor: root.theme.ink
                    selectedTextColor: root.theme.background
                    padding: root.theme.fontSize
                    background: Rectangle {
                        color: root.theme.background
                        border.color: root.theme.ink
                        border.width: search.activeFocus ? root.theme.ruleWidth * 2 : root.theme.ruleWidth
                    }
                    onTextChanged: {
                        if (root.secretItem)
                            return;
                        root.selectedIndex = 0;
                        root.clearDangerConfirmation();
                        results.positionViewAtBeginning();
                        // Drop in-flight answers for the old text and keep only
                        // suggestions the new text still prefixes.
                        const query = text.trim().toLowerCase();
                        if (root.mode === "web" && query !== root.webQuery) {
                            root.webQuery = query;
                            root.webGeneration++;
                            const kept = query ? root.webSuggestions.filter(value => value.toLowerCase().startsWith(query)) : [];
                            if (kept.length !== root.webSuggestions.length)
                                root.webSuggestions = kept;
                            suggestTimer.restart();
                        }
                    }
                    Keys.onPressed: event => root.handleKey(event, true)
                }

                ListView {
                    id: results
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.mode !== "journal"
                    clip: true
                    spacing: root.theme.pressOffset + root.theme.ruleWidth
                    model: root.visibleItems
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    delegate: PressButton {
                        id: result
                        activeFocusOnTab: false
                        required property var modelData
                        required property int index
                        readonly property bool application: root.mode === "launcher"
                        readonly property bool web: root.mode === "web"
                        readonly property bool game: root.mode === "games"
                        readonly property bool confirming: !!root.confirmationItem && root.confirmationItem.key === modelData.key
                        readonly property bool awaitingSecret: !!root.secretItem && root.secretItem.id === modelData.id
                        theme: root.theme
                        width: results.width - root.theme.fontSize
                        height: root.theme.listRowHeight + root.theme.pressOffset
                        selected: index === root.selectedIndex
                        hoverable: false
                        dangerous: !!modelData.destructive
                        Accessible.name: application ? modelData.name : (web ? modelData.label + ", " + modelData.description : modelData.label)
                        Accessible.description: confirming ? "Armed. Enter confirms, Escape cancels." : (web ? "" : (game ? [modelData.description, "Shift+Enter plays in Steam"].filter(Boolean).join(". ") : (modelData.description || "")))
                        onClicked: {
                            if (!root.open || pointerGuard.running)
                                return;
                            pointerGuard.restart();
                            root.pointerActivation = true;
                            root.selectedIndex = index;
                            root.launchSelected();
                            root.pointerActivation = false;
                            // A secured network just handed focus to the password field.
                            if (!root.secretItem)
                                root.focusKeys();
                        }
                        // Keep confirmation and navigation in the panel's key handler.
                        Keys.onPressed: event => root.handleKey(event, false)
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: root.theme.ruleWidth * 2
                            spacing: root.theme.fontSize
                            PressKey {
                                theme: root.theme
                                visible: !result.application && !result.game
                                text: result.modelData.key || ""
                                inverted: result.inverted
                            }
                            IconImage {
                                visible: result.application || result.game
                                implicitWidth: root.theme.listIconSize
                                implicitHeight: root.theme.listIconSize
                                source: result.application ? (Quickshell.iconPath(result.modelData.icon || "application-x-executable", true) || Qt.resolvedUrl("application.svg")) : (result.game ? root.gameIcon(result.modelData) : "")
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    Layout.fillWidth: true
                                    text: result.application ? result.modelData.name : result.modelData.label
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                    color: result.foreground
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize
                                    font.bold: true
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: result.confirming ? "Enter or tap again confirms · Esc cancels" : (result.awaitingSecret ? root.secretItem.secret + " above · Enter connects · Esc cancels" : (result.application ? (result.modelData.genericName || result.modelData.comment || "") : (result.modelData.description || "")))
                                    textFormat: Text.PlainText
                                    visible: text !== ""
                                    elide: Text.ElideRight
                                    color: result.inverted ? root.theme.background : (result.confirming ? root.theme.danger : root.theme.textMuted)
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize - 2
                                }
                            }
                            Text {
                                visible: !!result.modelData.items || !!result.modelData.targetMode
                                text: "›"
                                color: result.foreground
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.headingSize
                                font.bold: true
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.visibleItems.length === 0
                        text: root.modeText[root.mode].empty
                        color: root.theme.textMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.mode === "journal"
                    spacing: root.theme.fontSize
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: root.theme.fontSize * 50
                        color: root.theme.background
                        border.color: root.theme.ink
                        border.width: root.theme.ruleWidth
                        QMLTermWidget {
                            id: journalTerminal
                            anchors.fill: parent
                            anchors.margins: root.theme.ruleWidth * 2
                            visible: root.presented && root.mode === "journal"
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
                                        root.modeRequested("commands");
                                }
                            }
                            Keys.priority: Keys.BeforeItem
                            Keys.onPressed: event => {
                                if (root.isOverlayKey(event))
                                    event.accepted = true;
                            }
                            Keys.onReleased: event => {
                                if (root.isOverlayKey(event)) {
                                    root.dismissed();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        visible: panel.width >= root.theme.fontSize * 75
                        Layout.fillWidth: false
                        Layout.preferredWidth: root.theme.fontSize * 22
                        Layout.alignment: Qt.AlignTop
                        Text {
                            text: Qt.formatDateTime(root.now, "MMMM yyyy").toUpperCase()
                            color: root.theme.ink
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSize
                            font.bold: true
                        }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 7
                            Repeater {
                                model: ["M", "T", "W", "T", "F", "S", "S"]
                                Text {
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
                                Rectangle {
                                    required property int index
                                    readonly property int day: index - root.leadingDays + 1
                                    readonly property bool today: day === root.now.getDate()
                                    Layout.fillWidth: true
                                    implicitHeight: root.theme.controlSize
                                    color: today ? root.theme.ink : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.day > 0 && parent.day <= root.daysInMonth ? parent.day : ""
                                        color: parent.today ? root.theme.background : root.theme.ink
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSize - 1
                                        font.bold: parent.today
                                    }
                                }
                            }
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: root.mode === "journal" ? (root.journalDate === Qt.formatDateTime(root.now, "yyyy-MM-dd") ? root.journalDate + ".norg · Mod+Space closes" : "Session started " + root.journalDate + " · :JournalToday opens today · Mod+Space closes") : (root.confirmationItem ? "ENTER / Y / TAP  CONFIRM     ESC  CANCEL" : (root.secretItem ? "ENTER  CONNECT     ESC  CANCEL" : (root.mode === "games" ? "ENTER  PLAY     SHIFT+ENTER  PLAY IN STEAM     " + (root.steamEntry ? "CTRL+S  OPEN STEAM     " : "") + "ESC  " : (root.mode === "network" ? "↑ ↓  SELECT     ENTER  CONNECT     CTRL+R  RESCAN     ESC  " : "↑ ↓  SELECT     ENTER  OPEN     ESC  ")) + (search.text ? "CLEAR" : "BACK")))
                    elide: Text.ElideRight
                    color: root.confirmationItem ? root.theme.danger : root.theme.textMuted
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize - 2
                    font.bold: !!root.confirmationItem
                }
            }
        }
    }
}
