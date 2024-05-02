-- [nfnl] Compiled from fnl/plugins/rose-pine.fnl by https://github.com/Olical/nfnl, do not edit.
do end (require("rose-pine")).setup({dark_variant = "moon"})
vim.cmd("colorscheme rose-pine")
do
  local appearance = os.getenv("WINDOW_APPEARANCE")
  if (appearance == nil) then
    apppearance = "dark"
  else
  end
  vim.api.nvim_set_option_value("background", appearance, {})
end
vim.g.neovide_theme = "auto"
return nil
