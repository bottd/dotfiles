-- [nfnl] Compiled from fnl/general_config.fnl by https://github.com/Olical/nfnl, do not edit.
vim.api.nvim_command("set number")
vim.api.nvim_command("set cursorline")
vim.api.nvim_command("set smartindent")
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.foldlevelstart = 99
vim.opt.spell = true
vim.opt.spelllang = {"en_us"}
vim.keymap.set("n", "<Leader>y", "\"+y", {desc = "Yank to clipboard"})
return vim.keymap.set("t", "<Esc>", "<C-\\\\><C-n>")
