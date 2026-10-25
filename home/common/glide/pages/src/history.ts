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

/** glide.ts → page: `{ type: historyMessage, graph }`. The page asks for it
 * by setting `data-history-wanted` on its root element. */
export const historyMessage = "glide-history";
