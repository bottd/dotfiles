/// <reference types="./glide.d.ts" />

const newtabPath = glide.path.join(
  glide.path.home_dir,
  ".local",
  "share",
  "glide-pages",
  "index.html",
);
glide.o.newtab_url = new URL(`file://${newtabPath}`).href;

glide.keymaps.set("normal", "<leader>c", "config_reload");

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
];

addons.forEach(({ url, ...options }) => glide.addons.install(url, options));
