-- [nfnl] Compiled from fnl/plugins/theme.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  do
    local rose_pine = require("rose-pine")
    rose_pine.setup({dark_variant = "moon"})
  end
  local auto_dark_mode = require("auto-dark-mode")
  local function _2_()
    vim.api.nvim_set_option("background", "dark")
    return vim.cmd("colorscheme rose-pine")
  end
  local function _3_()
    vim.api.nvim_set_option("background", "light")
    return vim.cmd("colorscheme rose-pine")
  end
  auto_dark_mode.setup({update_interval = 1000, set_dark_mode = _2_, set_light_mode = _3_})
  return auto_dark_mode.init()
end
local function _4_()
  local ibl = require("ibl")
  return ibl.setup({indent = {char = "\226\148\130"}, scope = {enabled = true}})
end
return {{"rose-pine/neovim", name = "rose-pine", priority = 1000, dependencies = {"f-person/auto-dark-mode.nvim"}, config = _1_, lazy = false}, {"lukas-reineke/indent-blankline.nvim", main = "ibl", config = _4_, opts = {space_char_blankline = " ", show_current_context = true, show_current_context_start = true}}}
