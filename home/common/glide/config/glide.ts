/// <reference types="./glide.d.ts" />

// The startup/home page is set by policy in default.nix, which applies
// before this config loads.
glide.o.newtab_url = "https://drake.bot";

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
  {
    // Saves pages to deck.drena.haus (loge); sign in via the extension's options.
    url: "https://addons.mozilla.org/firefox/downloads/latest/readeck/latest.xpi",
  },
];

addons.forEach(({ url, ...options }) => glide.addons.install(url, options));
