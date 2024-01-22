-- [nfnl] Compiled from fnl/plugins/theme.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  return (require("rose-pine")).setup({dark_variant = "moon"})
end
local function _2_()
  local ibl = require("ibl")
  return ibl.setup({indent = {char = "\226\148\130"}, scope = {enabled = true}})
end
local function _3_()
  vim.api.nvim_set_option("background", "dark")
  return vim.cmd("colorscheme rose-pine")
end
local function _4_()
  vim.api.nvim_set_option("background", "light")
  return vim.cmd("colorscheme rose-pine")
end
return {{"rose-pine/neovim", name = "rose-pine", priority = 1000, config = _1_, lazy = false}, {"lukas-reineke/indent-blankline.nvim", main = "ibl", config = _2_, opts = {space_char_blankline = " ", show_current_context = true, show_current_context_start = true}}, {"f-person/auto-dark-mode.nvim", config = {update_interval = 1000, set_dark_mode = _3_, set_light_mode = _4_}}}
