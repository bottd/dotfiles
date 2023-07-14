return {
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
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
