/// <reference types="./glide.d.ts" />

const newtabPath = glide.path.join(
  glide.path.home_dir,
  ".local",
  "share",
  "glide-pages",
  "index.html",
);
glide.o.newtab_url = new URL(`file://${newtabPath}`).href;

// Browsing history for the new tab's History view, which can't read history
// from a file:// page. One node per site, sized by the distinct pages visited
// there; links are visits whose referring page was on another site. Built only
// when the page asks (its History view is showing). Keep the shape and message
// name in step with pages/src/history.ts.
type HistoryGraph = {
  days: number;
  sites: { id: string; pages: number }[];
  links: { source: string; target: string; clicks: number }[];
};

const historyDays = 30;
const historySiteLimit = 150;
// The build in flight or done, so tabs asking at once share one.
let historyCache: { at: number; graph: Promise<HistoryGraph> } | undefined;

function historySite(url: string) {
  try {
    const { protocol, hostname } = new URL(url);
    return protocol === "http:" || protocol === "https:"
      ? hostname.replace(/^www\./, "")
      : undefined;
  } catch {
    return undefined;
  }
}

function historyGraph(): Promise<HistoryGraph> {
  if (!historyCache || Date.now() - historyCache.at > 5 * 60_000) {
    const graph = buildHistoryGraph();
    historyCache = { at: Date.now(), graph };
    graph.catch(() => (historyCache = undefined));
  }
  return historyCache.graph;
}

async function buildHistoryGraph(): Promise<HistoryGraph> {
  const since = Date.now() - historyDays * 86_400_000;
  const items = await browser.history.search({
    text: "",
    startTime: since,
    maxResults: 5_000,
  });

  // Rank sites from the search alone; visits are only fetched for the sites
  // that make the cut, since a link needs both ends shown.
  const urlsBySite = new Map<string, string[]>();
  for (const { url } of items) {
    const site = url && historySite(url);
    if (!site) continue;
    const urls = urlsBySite.get(site);
    if (urls) urls.push(url);
    else urlsBySite.set(site, [url]);
  }
  const sites = [...urlsBySite]
    .map(([id, urls]) => ({ id, pages: urls.length }))
    .sort((a, b) => b.pages - a.pages)
    .slice(0, historySiteLimit);

  // Each getVisits is a history-database query in the parent process; a few
  // workers take turns instead of thousands queueing at once.
  const pending = sites.flatMap(({ id: site }) =>
    urlsBySite.get(site)!.map((url) => ({ site, url })),
  );
  const visitSite = new Map<string, string>();
  const referrals: { site: string; from: string }[] = [];
  const worker = async () => {
    for (let next = pending.pop(); next; next = pending.pop()) {
      const { site, url } = next;
      for (const visit of await browser.history.getVisits({ url })) {
        if ((visit.visitTime ?? 0) < since) continue;
        visitSite.set(visit.visitId, site);
        if (visit.referringVisitId && visit.referringVisitId !== "-1") {
          referrals.push({ site, from: visit.referringVisitId });
        }
      }
    }
  };
  await Promise.all(Array.from({ length: 16 }, worker));

  const clicks = new Map<string, number>();
  for (const { site, from } of referrals) {
    const source = visitSite.get(from);
    if (!source || source === site) continue;
    const key = `${source} ${site}`;
    clicks.set(key, (clicks.get(key) ?? 0) + 1);
  }
  const links = [...clicks].map(([key, count]) => {
    const [source, target] = key.split(" ");
    return { source, target, clicks: count };
  });

  return { days: historyDays, sites, links };
}

// Runs in the new tab: posts the graph to the page.
function postHistory(graph: HistoryGraph) {
  window.postMessage({ type: "glide-history", graph }, "*");
}

// One messenger per new-tab tab: a message carries no sender, so the
// receiver closes over the tab it answers rather than guessing the active
// one (which by then may be some other site).
const historyMessengers = new Map<
  number,
  glide.ParentMessenger<{ history_request: null }>
>();

function historyMessenger(tab_id: number) {
  let messenger = historyMessengers.get(tab_id);
  if (!messenger) {
    messenger = glide.messengers.create(async () => {
      try {
        const graph = await historyGraph();
        await glide.content.execute(postHistory, { tab_id, args: [graph] });
      } catch (error) {
        console.error("New tab history: failed to send the graph", error);
      }
    });
    historyMessengers.set(tab_id, messenger);
  }
  return messenger;
}

// The page asks for history by setting data-history-wanted on its root
// element once its History view shows. An attribute, unlike an event, is
// still there if the page set it before this watcher was installed.
glide.autocmds.create(
  "UrlEnter",
  /\/glide-pages\/index\.html$/,
  ({ tab_id }) => {
    historyMessenger(tab_id).content.execute(
      (messenger) => {
        const root = document.documentElement;
        if (root.dataset.glideHistory) return;
        root.dataset.glideHistory = "watching";
        const askIfWanted = () => {
          if (!root.dataset.historyWanted) return;
          observer.disconnect();
          messenger.send("history_request");
        };
        const observer = new MutationObserver(askIfWanted);
        observer.observe(root, { attributeFilter: ["data-history-wanted"] });
        askIfWanted();
      },
      { tab_id },
    );
  },
);

glide.keymaps.set("normal", "<leader>c", "config_reload");

// Dither Press chrome: rules in press.css, palette generated from Stylix.
Promise.all([
  glide.fs.read("press-palette.css", "utf8"),
  glide.fs.read("press.css", "utf8"),
])
  .then(([palette, rules]) =>
    glide.styles.add(palette + rules, { id: "dither-press", overwrite: true }),
  )
  .catch((error) => {
    console.error("Dither Press: failed to load chrome styles", error);
  });

glide.prefs.set("sidebar.revamp", true);
glide.prefs.set("sidebar.verticalTabs", true);

type Addon = glide.AddonInstallOptions & {
  url: string;
};
const addons: Addon[] = [
  {
    url: "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
    private_browsing_allowed: true,
  },
  {
    url: "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi",
    private_browsing_allowed: true,
  },
  {
    url: "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi",
  },
  {
    url: "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi",
  },
  {
    url: "https://addons.mozilla.org/firefox/downloads/latest/remove-youtube-s-suggestions/latest.xpi",
  },
  {
    url: "https://addons.mozilla.org/firefox/downloads/latest/per-tab-volume-control-xpi/latest.xpi",
    private_browsing_allowed: true,
  },
];

addons.forEach(({ url, ...options }) => glide.addons.install(url, options));
