local wezterm = require("wezterm")
local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

local function get_appearance()
  if wezterm.gui then
    return string.lower(wezterm.gui.get_appearance())
  else
    return "dark"
  end
end

local function scheme_for_appearance()
  local appearance = get_appearance()
  if appearance:find("dark") then
    return "Catppuccin Mocha"
  else
    return "Catppuccin Latte"
  end
end

local function config_reload(window)
  local overrides = (window:get_config_overrides() or {})
  local scheme = scheme_for_appearance()
  if overrides.color_scheme ~= scheme then
    overrides["color_scheme"] = scheme
    overrides["set_environment_variables"] = { WINDOW_APPEARANCE = get_appearance() }
    return window:set_config_overrides(overrides)
  else
    return nil
  end
end

wezterm.on("window-config-reloaded", config_reload)
local options = {
  color_scheme = scheme_for_appearance(),
  set_environment_variables = {
    WINDOW_APPEARANCE = get_appearance(),
  },
  front_end = "WebGpu",
  font = wezterm.font("MonoLisa Variable"),
  font_size = 13,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  leader = { key = "a", mods = "CTRL", timeout_miliseconds = 1000 },
  keys = {
    { key = "/", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  },
  window_decorations = "RESIZE",
  use_fancy_tab_bar = false,
}

if is_darwin then
  options.set_environment_variables.XDG_CONFIG_HOME = os.getenv("HOME") .. "/.config"
end

if is_linux then
  options.default_prog = { "/home/drake/.cargo/bin/nu" }
end
return options
