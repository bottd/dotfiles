-- Treesitter
local ts = require 'nvim-treesitter.configs'
ts.setup({
  ensure_installed = 'maintained', 
  highlight = {
    enable = true,
    use_languagetree = true,
  }
})

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.typescript.used_by = "javascriptflow"
