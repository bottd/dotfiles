-- [nfnl] Compiled from fnl/general-config.fnl by https://github.com/Olical/nfnl, do not edit.
vim.g.mapleader = " "
vim.keymap.set("n", "<Leader>y", "\"+y", {desc = "Yank to clipboard"})
vim.keymap.set("t", "<Esc>", "<C-\\\\><C-n>")
vim.o.winwidth = 10
vim.o.winminwidth = 10
vim.o.equalalways = false
return nil
