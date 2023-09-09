return {
  -- Useful lua functions used by lots of plugins
  'nvim-lua/plenary.nvim',
  'MunifTanjim/nui.nvim',

  -- Tmux/vim navigation
  'christoomey/vim-tmux-navigator',

  -- Vim Util plugins
  'gioele/vim-autoswap',
  {
    'NvChad/nvim-colorizer.lua',
    config = true
  },

  -- Run snippets inline!
  {
    'michaelb/sniprun',
    build = 'bash ./install.sh',
    config = true,
    keys = {
      { mode = 'v', '<leader>r', '<Plug>SnipRun<Cr>' },
      { mode = 'n', '<leader>rr', '<Plug>SnipRun<Cr>'},
      { mode = 'n', '<leader>ro', '<Plug>SnipRunOperator<Cr>'}
    }
  },
}
