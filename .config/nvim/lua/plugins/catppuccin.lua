-- [nfnl] Compiled from fnl/plugins/catppuccin.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("catppuccin")
local setup = _local_1_["setup"]
local function _2_(colors)
  return {MiniIndentscopeSymbol = {fg = colors.lavender}}
end
return setup({background = {light = "latte", dark = "mocha"}, flavor = "auto", custom_highlights = _2_})
