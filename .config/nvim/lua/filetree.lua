-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
  git = {
    enable = true,
  }
})

vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<Cr>');
