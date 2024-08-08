-- [nfnl] Compiled from fnl/general-config.fnl by https://github.com/Olical/nfnl, do not edit.
vim.api.nvim_command("set number")
vim.api.nvim_command("set cursorline")
vim.api.nvim_command("set smartindent")
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.foldlevelstart = 99
vim.opt.spell = true
vim.opt.spelllang = {"en_us"}
vim.o.guifont = "MonoLisa Nerd Font"
vim.g.mapleader = " "
vim.keymap.set("n", "<Leader>y", "\"+y", {desc = "Yank to clipboard"})
vim.keymap.set("t", "<Esc>", "<C-\\\\><C-n>")
vim.o.winwidth = 10
vim.o.winminwidth = 10
vim.o.equalalways = false
return nil
