vim.opt.conceallevel = 3
vim.api.nvim_command('set nonumber')
vim.api.nvim_command('set linebreak')
vim.api.nvim_command('set breakindent')

-- Disable nvim-tree keymaps
-- vim.keymap.del('n', '<C-n>')
-- vim.keymap.del('n', '<C-m>')

-- Override telescope keymaps
vim.keymap.set('n', '<leader>ff', ':Telescope neorg find_norg_files<Cr>', { desc = "Find Norg Files"});
vim.keymap.set('n', '<leader>nw', ':Telescope neorg switch_workspace<Cr>', { desc = "Switch Workspace" });
