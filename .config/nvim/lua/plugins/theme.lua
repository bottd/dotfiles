-- [nfnl] Compiled from fnl/plugins/theme.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  do end (require("rose-pine")).setup({dark_variant = "moon"})
  vim.cmd("colorscheme rose-pine")
  local apperance = os.getenv("window_appearance")
  if (appearance == nil) then
    apppearance = "dark"
  else
  end
  return vim.api.nvim_set_option_value("background", appearance, {})
end
local function _3_()
  local ibl = require("ibl")
  return ibl.setup({indent = {char = "\226\148\130"}, scope = {enabled = true}})
end
return {{"rose-pine/neovim", name = "rose-pine", priority = 1000, config = _1_, lazy = false}, {"lukas-reineke/indent-blankline.nvim", main = "ibl", config = _3_, opts = {space_char_blankline = " ", show_current_context = true, show_current_context_start = true}}}
