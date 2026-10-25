import { store, stored } from "./storage";

/** A URL's hostname without `www.`, or "" when it doesn't parse. */
export function siteHost(url: string) {
  try {
    return new URL(url).hostname.replace(/^www\./, "");
  } catch {
    return "";
  }
}

/** The site's own favicon, so visited hosts go to no icon service. */
export function faviconUrl(host: string) {
  return `https://${host}/favicon.ico`;
}

// Hosts whose favicon failed to load, with when, remembered for a week so a
// new tab shows their letter tile straight away instead of asking again.
// Reactive, so markup reading faviconMissing() swaps to the letter tile.
const missingKey = "missing-favicons";
const missingFor = 7 * 86_400_000;

function loadMissing() {
  let saved: Record<string, number> = {};
  try {
    saved = JSON.parse(stored(missingKey) ?? "{}");
  } catch {
    // A corrupt entry is as good as none.
  }
  return Object.fromEntries(
    Object.entries(saved).filter(([, at]) => Date.now() - at < missingFor),
  );
}

const missing: Record<string, number> = $state(loadMissing());
let saving = false;

export function faviconMissing(host: string) {
  return host in missing;
}

export function markFaviconMissing(host: string) {
  missing[host] = Date.now();
  // Failures arrive in bursts (a graph of tiles); write once per burst.
  if (saving) return;
  saving = true;
  queueMicrotask(() => {
    saving = false;
    store(missingKey, JSON.stringify(missing));
  });
}
