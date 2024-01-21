-- [nfnl] Compiled from after/ftplugin/norg.fnl by https://github.com/Olical/nfnl, do not edit.
vim.opt.conceallevel = 3
vim.api.nvim_command("set nonumber")
vim.api.nvim_command("set linebreak")
vim.api.nvim_command("set breakindent")
vim.keymap.set("n", "<leader>ff", ":Telescope neorg find_norg_files<Cr>", {desc = "Find Norg Files"})
return vim.keymap.set("n", "<leader>nw", ":Telescope neorg switch_workspace<Cr>", {desc = "Switch Workspace"})
