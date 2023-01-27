--[[
               Lualine section mappings
  +-------------------------------------------------+
  | A | B | C                             X | Y | Z |
  +-------------------------------------------------+
     https://github.com/nvim-lualine/lualine.nvim
]]--

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'nightfox',
    component_separators = '|',
    section_separators = { left = '', right = '' },
    globalstatus = true,
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = { 'lsp_progress' },
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  tabline = {},
  winbar = {
    lualine_a = {'filename'}
  },
  inactive_winbar = {
    lualine_a = {'filename'}
  },
  extensions = {}
}
