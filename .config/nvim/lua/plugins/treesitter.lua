return {
  { 
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'windwp/nvim-ts-autotag',
      'nvim-treesitter/nvim-treesitter-context'
    },
    build = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
    config = function()
      local ts = require 'nvim-treesitter.configs'
      ts.setup({
        ensure_installed = {
        'comment',
        'css',
        'diff',
        'fish',
        'gitignore',
        'graphql',
        'html',
        'json',
        'markdown',
        'markdown_inline',
        'norg',
        'lua',
        'python',
        'rust',
        'sql',
        'svelte',
        'toml',
        'tsx',
        'typescript'
      },
      autotag = {
        enable = true
      },
      highlight = {
        enable = true,
        use_languagetree = true,
      }
    })
    end
  },
  {
    'numToStr/Comment.nvim',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim')
          .create_pre_hook(),
      }
    end
  }
}
