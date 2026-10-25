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
// there; links are visits whose referring page was on another site. Keep the
// shape in step with pages/src/history.ts.
type HistoryGraph = {
  days: number;
  sites: { id: string; pages: number }[];
  links: { source: string; target: string; clicks: number }[];
};

const historyDays = 30;
const historySiteLimit = 150;
let historyCache: { at: number; graph: HistoryGraph } | undefined;

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

async function historyGraph(): Promise<HistoryGraph> {
  if (historyCache && Date.now() - historyCache.at < 5 * 60_000) {
    return historyCache.graph;
  }

  const since = Date.now() - historyDays * 86_400_000;
  const items = await browser.history.search({
    text: "",
    startTime: since,
    maxResults: 5_000,
  });
  const pages = new Map<string, number>();
  const visitSite = new Map<string, string>();
  const referrals: { site: string; from: string }[] = [];

  await Promise.all(
    items.map(async ({ url }) => {
      const site = url && historySite(url);
      if (!site) return;
      pages.set(site, (pages.get(site) ?? 0) + 1);

      for (const visit of await browser.history.getVisits({ url })) {
        if ((visit.visitTime ?? 0) < since) continue;
        visitSite.set(visit.visitId, site);
        if (visit.referringVisitId && visit.referringVisitId !== "-1") {
          referrals.push({ site, from: visit.referringVisitId });
        }
      }
    }),
  );

  const sites = [...pages]
    .map(([id, count]) => ({ id, pages: count }))
    .sort((a, b) => b.pages - a.pages)
    .slice(0, historySiteLimit);
  const shown = new Set(sites.map(({ id }) => id));

  const clicks = new Map<string, number>();
  for (const { site, from } of referrals) {
    const source = visitSite.get(from);
    if (!source || source === site || !shown.has(source) || !shown.has(site)) {
      continue;
    }
    const key = `${source} ${site}`;
    clicks.set(key, (clicks.get(key) ?? 0) + 1);
  }
  const links = [...clicks].map(([key, count]) => {
    const [source, target] = key.split(" ");
    return { source, target, clicks: count };
  });

  const graph = { days: historyDays, sites, links };
  historyCache = { at: Date.now(), graph };
  return graph;
}

// Runs in the new tab. Posts the graph now, and again whenever the page asks
// (it asks once on load, in case this ran first).
function postHistory(graph: HistoryGraph) {
  const send = () => window.postMessage({ type: "glide-history", graph }, "*");
  const root = document.documentElement;
  if (!root.dataset.glideHistory) {
    root.dataset.glideHistory = "listening";
    window.addEventListener("message", (event) => {
      if (event.data?.type === "glide-history-request") send();
    });
  }
  send();
}

glide.autocmds.create(
  "UrlEnter",
  /\/glide-pages\/index\.html$/,
  async ({ tab_id }) => {
    try {
      const graph = await historyGraph();
      await glide.content.execute(postHistory, { tab_id, args: [graph] });
    } catch (error) {
      console.error("New tab history: failed to send the graph", error);
    }
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
