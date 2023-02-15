-- Treesitter
local ts = require 'nvim-treesitter.configs'
ts.setup({
  ensure_installed = 'all',
  autotag = {
    enable = true
  },
  highlight = {
    enable = true,
    use_languagetree = true,
  }
})

-- Configure comment with treesitter context
require('Comment').setup {
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim')
    .create_pre_hook(),
}
