-- TODO: 
-- Install telescope
-- Configure tree sitter
-- Install nvim-cmp
require('plugins');
require('statusline');
require('theme');
require('completion');
require('git');
require('telescope-config');
require'mapx'.setup{ global = true }

nnoremap('<C-n>', ':NvimTreeToggle<Cr>')

-- Vim settings
vim.api.nvim_command('set number')
vim.api.nvim_command('set cursorline')
vim.api.nvim_command('set smartindent')
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
