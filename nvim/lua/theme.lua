-- Nightfox has multiple variants, one must be loaded for theme to work
-- nordfox, dayfox, dawnfox, duskfox
require('nightfox').load('duskfox')
require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}
