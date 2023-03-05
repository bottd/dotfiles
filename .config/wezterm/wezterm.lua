local wezterm = require 'wezterm'

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)
local SOLID_LEFT_CIRCLE = utf8.char(0xE3)

-- convert tabindex into color go from front to back fade
-- what is the operation to do this?
-- 1 2 3 4 5 6 7 8 9 10 11 12
-- 0 1 2 3 2 1 0 1 2 3 2 1 0

local colors_light = require('lua/rose-pine-dawn').colors()
local window_frame_light = require('lua/rose-pine-dawn').window_frame()

local colors_dark = require('lua/rose-pine-moon').colors()
local window_frame_dark = require('lua/rose-pine-moon').window_frame()


function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return colors_dark, window_frame_dark
  else
    return colors_light, window_frame_light
  end
end

wezterm.on('window-config-reloaded', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local colors, window_frame = scheme_for_appearance(appearance)
  if overrides.colors ~= colors then
    overrides.colors = colors
    overrides.window_frame = window_frame
    window:set_config_overrides(overrides)
  end
end)

return {
  colors = colors_light,
  window_frame = window_frame_light,
  font = wezterm.font 'MonoLisa Nerd Font',
  font_size = 13,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false
}
