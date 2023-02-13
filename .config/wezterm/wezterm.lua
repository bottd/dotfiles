local wezterm = require 'wezterm'

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

return {
  font = wezterm.font 'FiraCode Nerd Font Mono',
  font_size = 13,
  color_scheme = 'duskfox',
  tab_bar_at_bottom = true
}
