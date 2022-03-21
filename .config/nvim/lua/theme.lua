-- Nightfox has multiple variants, one must be loaded for theme to work
-- nordfox, dayfox, dawnfox, duskfox
vim.cmd("colorscheme nightfox");

-- require('nightfox').load('duskfox')
require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}

require("transparent").setup({
enable = true, -- boolean: enable transparent
extra_groups = { -- table/string: additional groups that should be clear
    -- example of akinsho/nvim-bufferline.lua
    -- "BufferLineTabClose",
    -- "BufferlineBufferSelected",
    -- "BufferLineFill",
    -- "BufferLineBackground",
    -- "BufferLineSeparator",
    -- "BufferLineIndicatorSelected",
  },
  exclude = {}, -- table: groups you don't want to clear
})
