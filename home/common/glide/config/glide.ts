/// <reference types="./glide.d.ts" />
//
// Glide config — "Neovim for the browser".
// This dir is an out-of-store symlink to ~/.config/glide, so edits here are
// live: save, then run `:config_reload` in Glide (or <leader>r below).
//
// One-time bootstrap for editor LSP/types: open Glide and run
//   :config_init home
// which generates ./glide.d.ts (+ tsconfig) next to this file.
//
// Docs: https://glide-browser.app/config  ·  https://glide-browser.app/cookbook

// --- options ---------------------------------------------------------------
// Space as leader to match your nvim `mapleader`. Note: in normal mode Space
// now starts a leader sequence instead of page-scrolling — use <C-d>/<C-f> or
// j/k to scroll. Set this back to "," etc. if you'd rather keep Space-scroll.
glide.g.mapleader = " ";
glide.o.which_key_delay = 300;

// --- helper: focus an existing tab for a host, else open it ----------------
async function jump_to(host: string, url: string) {
  const tab = await glide.tabs.get_first({ url: host });
  if (tab && tab.id) {
    await browser.tabs.update(tab.id, { active: true });
  } else {
    await browser.tabs.create({ url });
  }
}

// --- keymaps ---------------------------------------------------------------
// `;` -> command mode (no shift), the way you'd remap `:` in vim.
glide.keymaps.set("normal", ";", "keys :");

// vim-style nav in command-mode completion.
glide.keymaps.set("command", "<c-j>", "commandline_focus_next");
glide.keymaps.set("command", "<c-k>", "commandline_focus_back");

// <leader>r reloads this config without restarting — tight edit→test loop.
glide.keymaps.set("normal", "<leader>r", "config_reload", {
  description: "[r]eload glide config",
});

// <leader>y yank current page URL (mirrors your nvim <leader>y clipboard yank).
glide.keymaps.set(
  "normal",
  "<leader>y",
  async () => {
    const tab = await glide.tabs.active();
    if (tab?.url) await navigator.clipboard.writeText(tab.url);
  },
  { description: "[y]ank page url" },
);

// g-prefixed quick-jumps: focus the tab if it's open, else open it.
glide.keymaps.set(
  "normal",
  "gk",
  () => jump_to("kagi.com", "https://kagi.com"),
  {
    description: "[g]o to [k]agi",
  },
);
glide.keymaps.set(
  "normal",
  "gh",
  () => jump_to("github.com", "https://github.com"),
  {
    description: "[g]o to git[h]ub",
  },
);
glide.keymaps.set(
  "normal",
  "gy",
  () => jump_to("youtube.com", "https://youtube.com"),
  {
    description: "[g]o to [y]outube",
  },
);

// --- per-site native keyboard (ignore mode) --------------------------------
// On GitHub and YouTube, hand the keyboard to the page so their own shortcuts
// (j/k, the YouTube player, etc.) work. Normal mode is restored when you
// navigate away.
for (const hostname of ["github.com", "youtube.com"]) {
  glide.autocmds.create("UrlEnter", { hostname }, async () => {
    await glide.excmds.execute("mode_change ignore");
    return () => glide.excmds.execute("mode_change normal");
  });
}

// Escape hatch: Shift+Esc pulls control back to Glide while on an ignore-mode
// page (so you can still hit `gk`, `;`, etc. without leaving the tab).
glide.keymaps.set("ignore", "<S-Escape>", "mode_change normal");

// --- prefs (about:config, but in code) -------------------------------------
// Ensure the Mozilla account / Firefox Sync UI is available, then sign in via
// about:preferences#sync (bookmarks, passwords, history, open tabs sync like
// Firefox; the add-on list is the one flaky category).
glide.prefs.set("identity.fxaccounts.enabled", true);

// Other prefs, left commented — uncomment to taste:
// glide.prefs.set("browser.startup.homepage", "about:blank");
// glide.prefs.set("privacy.resistFingerprinting", true); // heavy; breaks some sites

// --- chrome styling --------------------------------------------------------
// Hide the native tab strip (you navigate by keys anyway). Commented until you
// want it:
// glide.styles.add(css`
//   #TabsToolbar { visibility: collapse !important; }
// `);
