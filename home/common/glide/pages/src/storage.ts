// Browser storage can be missing or throw (private windows, blocked site
// data); everything on the page works without it.

export function stored(key: string) {
  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
}

export function store(key: string, value: string) {
  try {
    localStorage.setItem(key, value);
  } catch {
    // Nothing to do; the value just isn't remembered.
  }
}
