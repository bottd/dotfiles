vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.keymap.set("n", "<Leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("t", "<Esc>", "<C-\\\\><C-n>")
