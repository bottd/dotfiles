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
local tab_colors = {"#569fba", "#65b1cd", "#a6dae3", "#e2e0f7"}

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    -- use tab.tabIndex to select tab color cycling through palette
    local cycle = math.floor(tab.tab_index / #tab_colors)
    local is_even_cycle = cycle % 2 == 1;
    local new_index = tab.tab_index - (cycle * #tab_colors)

    local background
    local edge_background = '#0b0022'
    -- local background = '#1b1032'
    local foreground = '#808080'

    if is_even_cycle then
      background = tab_colors[new_index]
      edge_background = tab_colors[new_index + 1]
    else
      background = tab_colors[new_index]
      edge_background = tab_colors[new_index - 1]
    end

    -- if tab.is_active then
    --   background = '#2b2042'
    --   foreground = '#c0c0c0'
    -- elseif hover then
    --   background = '#3b3052'
    --   foreground = '#909090'
    -- end

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    local title = wezterm.truncate_right(tab.active_pane.title, max_width - 2)

    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = '' },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = '' },
    }
  end
)

return {
  color_scheme = 'duskfox',
  font = wezterm.font 'FiraCode Nerd Font Mono',
  font_size = 13,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false
}
