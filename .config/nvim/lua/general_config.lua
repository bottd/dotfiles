-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Vim settings
vim.api.nvim_command('set number')
vim.api.nvim_command('set cursorline')
vim.api.nvim_command('set smartindent')
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.foldlevelstart = 99
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }


-- Copy to clipboard
vim.keymap.set('n', '<Leader>y', '"+y', { desc = "Yank to clipboard" });
