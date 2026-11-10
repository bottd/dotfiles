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
    // A row waiting for a password or SIM PIN; the search field takes it and
    // keeps it until the connection answers, so a typo is a retype, not a restart.
    property var secretItem: null
    property bool secretRevealed: false
    property string secretNote: ""
    property bool secretFailed: false
    readonly property string emptySecretNote: "Nothing typed yet"
    // What the shell knows, so toggle rows can say which way they will go and
    // rows this host can't perform stay off the chart.
    property var vpnStatus: ({})
    property bool backlightAvailable: true
    property bool audioAvailable: true
    // "on", "off", or "" until rfkill has answered.
    property string airplane: ""
    // The mode the panel was opened in. Esc closes from there; it only steps
    // back to COMMANDS from a mode that was reached through it.
    property string entryMode: "commands"
    property bool internalSwitch: false
    readonly property bool canGoBack: path.length > 0 || (mode !== "commands" && mode !== entryMode)

    // Ordered by group, then by the chart's reading order within a group.
    readonly property var menu: [
        {
            key: "d",
            group: "Launch",
            label: "Applications",
            description: "Find and launch an application",
            targetMode: "launcher"
        },
        {
            key: "g",
            group: "Launch",
            label: "Games",
            description: "Play an installed game",
            targetMode: "games"
        },
        {
            key: "j",
            group: "Launch",
            label: "Daily journal",
            description: "Today's page and calendar",
            targetMode: "journal"
        },
        {
            key: "w",
            group: "Launch",
            label: "Web",
            description: "Open a URL or search " + theme.searchName,
            targetMode: "web"
        },
        {
            key: "a",
            group: "Launch",
            label: "Pinned apps",
            description: "Discord and Glide",
            items: [
                {
                    key: "d",
                    label: "Discord",
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
            key: "p",
            group: "System",
            label: "Power",
            description: "Sleep, lock, reboot, power off",
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
            key: "m",
            group: "System",
            label: "Connections",
            description: "Network, VPN, airplane mode",
            items: [
                {
                    key: "a",
                    label: "Airplane mode",
                    description: airplane === "on" ? "On · every radio is blocked · Enter turns it off" : (airplane === "off" ? "Off · Enter blocks every radio" : "Blocks or unblocks every radio"),
                    command: ["sh", "-c", "if LC_ALL=C rfkill -n -o SOFT | grep -q unblocked; then rfkill block all; else rfkill unblock all; fi"]
                },
                {
                    key: "v",
                    label: "VPN exit node",
                    description: vpnDescription(),
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
            key: "s",
            group: "System",
            label: "Screenshot",
            description: "Select a region to capture",
            screenshot: true
        },
        {
            key: "v",
            group: "Levels",
            label: "Volume",
            description: "Arrows adjust · M mutes",
            shellAction: "volume"
        },
        {
            key: "b",
            group: "Levels",
            label: "Brightness",
            description: "Arrows adjust",
            shellAction: "brightness"
        }
    ]
    // The commands root is a printed key chart, not a list: every key shows at
    // once, set in two columns under its group. Searching or stepping into a
    // submenu falls back to the list.
    readonly property var chartGroups: [
        {
            name: "Launch",
            column: 0
        },
        {
            name: "System",
            column: 1
        },
        {
            name: "Levels",
            column: 1
        }
    ]
    readonly property bool charted: mode === "commands" && path.length === 0 && !search.text.trim()
    readonly property int chartRowHeight: Math.round(theme.fontSize * 3.25) + theme.pressOffset // 42
    readonly property int chartPitch: chartRowHeight + theme.pressOffset + theme.ruleWidth // 47
    readonly property int chartHeadingHeight: theme.fontSize * 2 // 24
    readonly property var chart: {
        const slots = [], headings = [], bottoms = [0, 0];
        if (charted) {
            for (const group of chartGroups) {
                const members = [];
                visibleItems.forEach((item, index) => {
                    if (item.group === group.name)
                        members.push(index);
                });
                if (!members.length)
                    continue;
                // More room above a group heading than below it.
                let y = bottoms[group.column] ? bottoms[group.column] + Math.round(theme.gap * 1.5) : 0;
                headings.push({
                    text: group.name.toUpperCase(),
                    column: group.column,
                    y: y
                });
                y += chartHeadingHeight;
                for (const index of members) {
                    slots[index] = {
                        column: group.column,
                        y: y
                    };
                    y += chartPitch;
                }
                bottoms[group.column] = y;
            }
        }
        return {
            slots: slots,
            headings: headings,
            height: Math.max(bottoms[0], bottoms[1])
        };
    }
    // The footer's key caps. Esc is labelled with what it will actually do.
    readonly property var hints: {
        const escape = ["ESC", search.text && !secretItem ? "Clear" : (canGoBack ? "Back" : "Close")];
        if (mode === "journal")
            return [["MOD+SPACE", "Close"]];
        if (confirmationItem)
            return [["ENTER / Y", "Confirm"], ["ESC", "Cancel"]];
        if (secretItem)
            return [["ENTER", "Connect"], ["CTRL+S", secretRevealed ? "Hide" : "Show"], ["ESC", "Cancel"]];
        if (mode === "games")
            return [["ENTER", "Play"], ["SHIFT+ENTER", "Play in Steam"]].concat(steamEntry ? [["CTRL+S", "Open Steam"]] : [], [escape]);
        if (mode === "network")
            return [["↑ ↓", "Select"], ["ENTER", "Connect"], ["CTRL+R", "Rescan"], escape];
        if (charted)
            return [["← ↑ ↓ →", "Move"], ["ENTER", "Open"], ["/", "Search"], escape];
        return [["↑ ↓", "Select"], ["ENTER", "Open"], escape];
    }
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
    readonly property var filteredCommands: mode !== "commands" ? [] : activeItems.filter(item => available(item) && (!search.text.trim() || fuzzyScore(search.text.trim().toLowerCase(), item.label + " " + (item.description || "")) > Number.NEGATIVE_INFINITY))
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
                // nf-md-cog, from the same Nerd range as the signal glyphs
                // the other rows carry; a bare gear falls back off-face.
                key: "󰒓",
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

    // A row the host can't perform is left off rather than shown dead.
    function available(item) {
        if (item.application && !findApplication(item.application))
            return false;
        if (item.targetMode === "games" && !theme.gamesListCommand.length)
            return false;
        if (item.shellAction === "brightness" && !backlightAvailable)
            return false;
        if (item.shellAction === "volume" && !audioAvailable)
            return false;
        return true;
    }
    // The vpn script's tooltip already says the state ("vpn: connected · Oslo,
    // Norway"); the row adds which way Enter will take it.
    function vpnDescription() {
        const note = (vpnStatus.tooltip || "").replace(/^vpn: /, "");
        if (!note)
            return "Turns the Tailscale exit node on or off";
        const state = note.charAt(0).toUpperCase() + note.slice(1);
        if (vpnStatus.tone === "positive")
            return state + " · Enter turns it off";
        return vpnStatus.tone === "muted" && /exit node/.test(note) ? state + " · Enter turns one on" : state;
    }
    function switchMode(target) {
        internalSwitch = true;
        modeRequested(target);
        internalSwitch = false;
    }
    function moveSelection(delta, wrap) {
        const count = visibleItems.length;
        if (!count)
            return;
        const next = selectedIndex + delta;
        selectedIndex = wrap ? (next % count + count) % count : Math.max(0, Math.min(count - 1, next));
        revealSelection();
    }
    function revealSelection() {
        if (!charted) {
            results.positionViewAtIndex(selectedIndex, ListView.Contain);
            return;
        }
        const slot = chart.slots[selectedIndex];
        if (!slot)
            return;
        if (slot.y - chartHeadingHeight < chartView.contentY)
            chartView.contentY = Math.max(0, slot.y - chartHeadingHeight);
        else if (slot.y + chartRowHeight > chartView.contentY + chartView.height)
            chartView.contentY = slot.y + chartRowHeight - chartView.height;
    }
    // Left and Right cross the chart's gutter to the row nearest in height.
    function crossColumn(column) {
        const here = chart.slots[selectedIndex];
        if (!here || here.column === column)
            return;
        let nearest = -1;
        chart.slots.forEach((slot, index) => {
            if (slot.column === column && (nearest < 0 || Math.abs(slot.y - here.y) < Math.abs(chart.slots[nearest].y - here.y)))
                nearest = index;
        });
        if (nearest >= 0) {
            selectedIndex = nearest;
            revealSelection();
        }
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
            // An open prompt follows its row, so a SIM's remaining tries stay current.
            const prompted = secretItem ? items.find(item => item.id === secretItem.id && item.secret) : null;
            if (prompted)
                secretItem = prompted;
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
            clearSecret();
            secretItem = item;
            search.forceActiveFocus();
            return;
        }
        runNetwork(item, "");
    }
    // The prompt stays open with what was typed until the connection answers:
    // success closes it, failure leaves the text selected under its reason.
    function submitSecret() {
        if (!secretItem || networkActionProcess.running)
            return;
        secretFailed = !search.text;
        secretNote = search.text ? "" : emptySecretNote;
        if (search.text)
            runNetwork(secretItem, search.text);
    }
    function clearSecret() {
        secretItem = null;
        secretRevealed = false;
        secretNote = "";
        secretFailed = false;
        search.text = "";
    }
    function cancelSecret() {
        clearSecret();
        focusKeys();
    }
    function secretAnswered(ok, message) {
        if (ok) {
            cancelSecret();
            return;
        }
        secretNote = message || "That didn't work";
        secretFailed = true;
        networkMessage = "";
        search.forceActiveFocus();
        search.selectAll();
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
        } else if (canGoBack)
            switchMode("commands");
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
            switchMode(item.targetMode);
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
            } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
                if (!event.isAutoRepeat)
                    secretRevealed = !secretRevealed;
                event.accepted = true;
            }
            return;
        }
        const selected = visibleItems[selectedIndex];
        if (event.key === Qt.Key_Escape && search.text) {
            search.text = "";
            event.accepted = true;
        } else if (mode === "network" && (event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_R) {
            if (!event.isAutoRepeat)
                refreshNetwork(true);
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            if (!event.isAutoRepeat)
                goBack();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace && !search.text) {
            // Steps back like Esc, but never closes the panel: an extra
            // Backspace after emptying the field must not throw the sheet away.
            if (!event.isAutoRepeat && canGoBack)
                goBack();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_N || event.key === Qt.Key_P))) {
            // A held key stops at the ends; a fresh press wraps, as the tray menu does.
            moveSelection(event.key === Qt.Key_Down || event.key === Qt.Key_N ? 1 : -1, !event.isAutoRepeat);
            if (!typing)
                focusKeys();
            event.accepted = true;
        } else if (event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) {
            const page = charted ? visibleItems.length : Math.max(1, Math.floor(results.height / (theme.listRowHeight + theme.pressOffset * 2 + theme.ruleWidth)) - 1);
            moveSelection(event.key === Qt.Key_PageDown ? page : -page, false);
            event.accepted = true;
        } else if (!typing && (event.key === Qt.Key_Home || event.key === Qt.Key_End)) {
            moveSelection(event.key === Qt.Key_End ? visibleItems.length : -visibleItems.length, false);
            event.accepted = true;
        } else if (!typing && charted && (event.key === Qt.Key_Left || event.key === Qt.Key_Right)) {
            crossColumn(event.key === Qt.Key_Right ? 1 : 0);
            event.accepted = true;
        } else if (!typing && mode === "commands" && event.key === Qt.Key_Left) {
            if (!event.isAutoRepeat && canGoBack)
                goBack();
            event.accepted = true;
        } else if (!typing && mode === "commands" && event.key === Qt.Key_Right) {
            if (!event.isAutoRepeat && selected && (selected.items || selected.targetMode))
                activate(selected);
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || (!typing && event.key === Qt.Key_Space)) {
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
        clearSecret();
        networkMessage = "";
        if (open) {
            entryMode = mode;
            airplaneProcess.running = true;
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
        // A keybind that swaps the mode under an open panel is a new entry point.
        if (!internalSwitch)
            entryMode = mode;
        // A new mode is a fresh proof pulled over the same sheet.
        if (open)
            panel.printIn();
        resetWeb();
        clearSecret();
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
                    root.networkMessage = "The network script gave no answer";
                    root.networkMessageOk = false;
                }
                if (root.secretItem)
                    root.secretAnswered(root.networkMessageOk, root.networkMessage);
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
    // Asked once per open, so the airplane row can say which way it will go.
    Process {
        id: airplaneProcess
        command: ["rfkill", "-n", "-o", "SOFT"]
        environment: ({
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: root.airplane = !text.trim() ? "" : (/\bunblocked\b/.test(text) ? "off" : "on")
        }
    }
    // NetworkManager changes underneath an open panel (cable, roaming).
    Timer {
        interval: 5000
        repeat: true
        running: root.open && root.mode === "network"
        onTriggered: root.refreshNetwork(false)
    }
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
                anchors.margins: root.theme.inset
                spacing: root.theme.gap

                RowLayout {
                    Layout.fillWidth: true
                    PressButton {
                        id: backButton
                        theme: root.theme
                        visible: root.canGoBack
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
                        // An armed command retitles the sheet: the question is
                        // asked at the size of the answer.
                        text: root.confirmationItem ? root.confirmationItem.label.toUpperCase() + "?" : (root.path.length ? root.path.map(entry => entry.label).join(" / ").toUpperCase() : root.modeText[root.mode].heading)
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
                            font.pixelSize: root.theme.captionSize
                            font.bold: root.gamesFailed
                        }
                    }
                    // Progress is a stamped caption; an outcome is a sentence, set
                    // as nmcli or the script worded it. A failure carries the
                    // danger square, so it reads on eink without its hue.
                    RowLayout {
                        id: networkStatus
                        readonly property bool busy: !!root.networkPending || root.networkScanning
                        readonly property bool failed: !busy && !root.networkMessageOk
                        readonly property string note: root.networkPending ? "WORKING ON " + root.networkPending.toUpperCase() + "…" : (root.networkScanning ? "SCANNING…" : root.networkMessage)
                        visible: root.mode === "network" && note !== ""
                        Layout.maximumWidth: root.theme.fontSize * 30
                        spacing: Math.round(root.theme.fontSize / 2.4)
                        Accessible.role: Accessible.StaticText
                        Accessible.name: note
                        Rectangle {
                            visible: networkStatus.failed
                            implicitWidth: Math.max(5, Math.round(root.theme.fontSize / 2.4))
                            implicitHeight: implicitWidth
                            color: root.theme.danger
                        }
                        Text {
                            Layout.fillWidth: true
                            text: networkStatus.note
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: networkStatus.failed ? root.theme.danger : root.theme.textMuted
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.captionSize
                            font.bold: networkStatus.failed
                        }
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

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.mode !== "journal"
                    spacing: root.theme.gap
                    TextField {
                        id: search
                        Layout.fillWidth: true
                        placeholderText: root.modeText[root.mode].placeholder
                        Accessible.name: root.modeText[root.mode].searchName
                        echoMode: root.secretItem && !root.secretRevealed ? TextInput.Password : TextInput.Normal
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
                            if (root.secretItem) {
                                // A rejected secret keeps its reason while it is
                                // retyped; "nothing typed" is answered by typing.
                                if (text && root.secretNote === root.emptySecretNote) {
                                    root.secretNote = "";
                                    root.secretFailed = false;
                                }
                                return;
                            }
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
                    PressButton {
                        id: revealButton
                        theme: root.theme
                        visible: !!root.secretItem
                        activeFocusOnTab: false
                        implicitWidth: root.theme.fontSize * 6
                        Accessible.name: root.secretRevealed ? "Hide what was typed" : "Show what was typed"
                        onClicked: {
                            root.secretRevealed = !root.secretRevealed;
                            search.forceActiveFocus();
                        }
                        Text {
                            anchors.centerIn: parent
                            text: root.secretRevealed ? "HIDE" : "SHOW"
                            color: revealButton.foreground
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSize
                            font.bold: true
                        }
                    }
                }

                // The prompt's own line, directly under the field it is about:
                // what is being asked, then why it was refused.
                RowLayout {
                    Layout.fillWidth: true
                    visible: !!root.secretItem
                    spacing: Math.round(root.theme.fontSize / 2.4)
                    Accessible.role: Accessible.StaticText
                    Accessible.name: secretLine.text
                    Rectangle {
                        visible: root.secretFailed
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: Math.round(root.theme.captionSize / 4)
                        implicitWidth: Math.max(5, Math.round(root.theme.fontSize / 2.4))
                        implicitHeight: implicitWidth
                        color: root.theme.danger
                    }
                    Text {
                        id: secretLine
                        Layout.fillWidth: true
                        text: root.secretNote ? root.secretNote + (root.secretNote === root.emptySecretNote ? "" : " · retype and press Enter") : (root.networkPending ? "Connecting…" : (root.secretItem ? root.secretItem.secret : ""))
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: root.secretFailed ? root.theme.danger : root.theme.textMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.captionSize
                        font.bold: root.secretFailed
                    }
                }

                Flickable {
                    id: chartView
                    readonly property int columnWidth: Math.floor((width - root.theme.gap) / 2)
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.charted
                    clip: true
                    contentHeight: root.chart.height
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: PressScrollBar {
                        theme: root.theme
                    }
                    Repeater {
                        model: root.chart.headings
                        Item {
                            required property var modelData
                            x: modelData.column * (chartView.columnWidth + root.theme.gap)
                            y: modelData.y
                            width: chartView.columnWidth - root.theme.pressOffset
                            height: root.chartHeadingHeight
                            Text {
                                anchors.left: parent.left
                                anchors.bottom: groupRule.top
                                anchors.bottomMargin: root.theme.ruleWidth
                                text: parent.modelData.text
                                color: root.theme.ink
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.captionSize
                                font.bold: true
                            }
                            Rectangle {
                                id: groupRule
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: Math.round(root.theme.fontSize / 2) // 6
                                width: parent.width
                                height: root.theme.ruleWidth
                                color: root.theme.ink
                            }
                        }
                    }
                    Repeater {
                        model: root.charted ? root.visibleItems : []
                        delegate: resultRow
                    }
                }

                ListView {
                    id: results
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.mode !== "journal" && !root.charted
                    clip: true
                    spacing: root.theme.pressOffset + root.theme.ruleWidth
                    model: root.charted ? [] : root.visibleItems
                    ScrollBar.vertical: PressScrollBar {
                        theme: root.theme
                    }
                    delegate: resultRow
                    Text {
                        anchors.centerIn: parent
                        visible: root.visibleItems.length === 0
                        text: root.modeText[root.mode].empty
                        color: root.theme.textMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize
                    }
                }

                // One row for the list and the chart: the chart sets it at a
                // slot, the list stacks it.
                Component {
                    id: resultRow
                    PressButton {
                        id: result
                        activeFocusOnTab: false
                        required property var modelData
                        required property int index
                        readonly property bool application: root.mode === "launcher"
                        readonly property bool web: root.mode === "web"
                        readonly property bool game: root.mode === "games"
                        readonly property bool confirming: !!root.confirmationItem && root.confirmationItem.key === modelData.key
                        readonly property bool awaitingSecret: !!root.secretItem && root.secretItem.id === modelData.id
                        readonly property var slot: root.charted ? root.chart.slots[index] || null : null
                        theme: root.theme
                        width: slot ? chartView.columnWidth : results.width - root.theme.fontSize
                        height: slot ? root.chartRowHeight : root.theme.listRowHeight + root.theme.pressOffset
                        Binding on x {
                            when: !!result.slot
                            value: result.slot ? result.slot.column * (chartView.columnWidth + root.theme.gap) : 0
                        }
                        Binding on y {
                            when: !!result.slot
                            value: result.slot ? result.slot.y : 0
                        }
                        selected: index === root.selectedIndex
                        hoverable: false
                        dangerous: !!modelData.destructive
                        // A row can outlive its mode by a frame, holding the other kind of entry.
                        Accessible.name: (application ? modelData.name : (web ? modelData.label + ", " + modelData.description : modelData.label)) || ""
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
                            spacing: root.theme.gap
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
                                    text: (result.application ? result.modelData.name : result.modelData.label) || ""
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                    color: result.foreground
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize
                                    font.bold: true
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: result.confirming ? "Enter or tap again confirms · Esc cancels" : (result.awaitingSecret ? "Waiting for what you type above" : (result.application ? (result.modelData.genericName || result.modelData.comment || "") : (result.modelData.description || "")))
                                    textFormat: Text.PlainText
                                    visible: text !== ""
                                    elide: Text.ElideRight
                                    color: result.inverted ? root.theme.background : (result.confirming ? root.theme.danger : root.theme.textMuted)
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.captionSize
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
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.mode === "journal"
                    spacing: root.theme.gap
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
                                        root.switchMode("commands");
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
                                    font.pixelSize: root.theme.captionSize
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
                // The footer is the sheet's legend: each key a small cap, each
                // label what that key does right now.
                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.theme.gap
                    clip: true
                    Text {
                        visible: root.mode === "journal"
                        text: root.journalDate === Qt.formatDateTime(root.now, "yyyy-MM-dd") ? root.journalDate + ".mg" : "Session started " + root.journalDate + " · :JournalToday opens today"
                        color: root.theme.textMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.captionSize
                    }
                    Rectangle {
                        visible: !!root.confirmationItem
                        implicitWidth: Math.max(5, Math.round(root.theme.fontSize / 2.4))
                        implicitHeight: implicitWidth
                        color: root.theme.danger
                    }
                    Repeater {
                        model: root.hints
                        Row {
                            required property var modelData
                            spacing: Math.round(root.theme.fontSize / 2) // 6
                            PressKey {
                                theme: root.theme
                                compact: true
                                text: parent.modelData[0]
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.modelData[1]
                                color: root.confirmationItem ? root.theme.danger : root.theme.textMuted
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.captionSize
                                font.bold: !!root.confirmationItem
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
