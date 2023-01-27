require('nvim-tree').setup({
  git = {
    enable = true,
  }
})

vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<Cr>');
