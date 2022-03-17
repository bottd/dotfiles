require('nvim-tree').setup({
  git = {
    enable = true,
  }
})

nnoremap('<C-n>', ':NvimTreeToggle<Cr>');
