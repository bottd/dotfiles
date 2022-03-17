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

nnoremap('<silent> {Left-Mapping}', ':TmuxNavigateLeft<cr>');
nnoremap('<silent> {Down-Mapping}', ':TmuxNavigateDown<cr>');
nnoremap('<silent> {Up-Mapping}', ':TmuxNavigateUp<cr>');
nnoremap('<silent> {Right-Mapping}', ':TmuxNavigateRight<cr>');
nnoremap('<silent> {Previous-Mapping}', ':TmuxNavigatePrevious<cr>');


-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts);
-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts);
