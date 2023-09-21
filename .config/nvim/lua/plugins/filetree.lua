return {
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function() 
      require'nvim-tree'.setup {
        git = {
          enable = true,
        },
        -- todo: how show .gitignored files?
        filters = {
          dotfiles = false,
        }
      } 
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<Cr>');
      vim.keymap.set('n', '<C-m>', ':NvimTreeFindFile<Cr>');
    end
  },

}
