-- [nfnl] Compiled from after/ftplugin/norg.fnl by https://github.com/Olical/nfnl, do not edit.
vim.opt.conceallevel = 3
vim.api.nvim_command("set nonumber")
vim.api.nvim_command("set linebreak")
vim.api.nvim_command("set breakindent")
return vim.keymap.set("n", "<Cr>", "<Plug>(neorg.esupports.hop.hop-link)")
