-- Vim keybinds
vim.g.mapleader = ' ';

-- Vim settings
vim.api.nvim_command('set number')
vim.api.nvim_command('set cursorline')
vim.api.nvim_command('set smartindent')
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.g.tmux_navigator_no_mappints = 1;
vim.keymap.set('n', '<C-h>', ':<C-U>TmuxNavigateLeft<Cr>')
vim.keymap.set('n', '<C-j>', ':<C-U>TmuxNavigateDown<Cr>')
vim.keymap.set('n', '<C-k>', ':<C-U>TmuxNavigateUp<Cr>')
vim.keymap.set('n', '<C-l>', ':<C-U>TmuxNavigateLeft<Cr>')
vim.keymap.set('n', '<C-\\>', ':<C-U>TmuxNavigatePrevious<Cr>')

-- Reload config
vim.keymap.set('n', '<leader>rc', ':source $MYVIMRC<Cr>')

-- Copy to clipboard
vim.keymap.set('n', '<Leader>y', '"+y');
