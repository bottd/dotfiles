// The browsing-history graph glide.ts (home/common/glide/config) posts to the
// new tab page, which can't read history itself from a file:// URL. Keep the
// shape and message names in step with that file.

export type HistorySite = {
  /** Hostname without `www.`. */
  id: string;
  /** Distinct pages visited on the site in the window. */
  pages: number;
};

export type HistoryLink = {
  source: string;
  target: string;
  /** Visits to `target` that came from a page on `source`. */
  clicks: number;
};

export type HistoryGraph = {
  days: number;
  sites: HistorySite[];
  links: HistoryLink[];
};

/** glide.ts → page: `{ type: historyMessage, graph }`. */
export const historyMessage = "glide-history";
/** page → glide.ts: ask again in case the graph arrived before the page. */
export const historyRequest = "glide-history-request";
