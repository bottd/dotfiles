-- [nfnl] Compiled from fnl/general-config.fnl by https://github.com/Olical/nfnl, do not edit.
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set("n", "<Leader>y", "\"+y", {desc = "Yank to clipboard"})
return vim.keymap.set("t", "<Esc>", "<C-\\\\><C-n>")
