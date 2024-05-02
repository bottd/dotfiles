-- [nfnl] Compiled from fnl/plugins/zen-mode.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local zen_mode = require("zen-mode")
  zen_mode.setup({plugins = {wezterm = {enabled = true}}})
end
return vim.keymap.set("n", "<leader>wz", ":ZenMode<Cr>", {desc = "Zen Mode"})
