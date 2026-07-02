/// <reference types="./glide.d.ts" />

glide.keymaps.set("normal", "<leader>c", "config_reload");

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
