-- [nfnl] Compiled from fnl/plugins/statusline.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  local lualine = require("lualine")
  return lualine.setup({options = {icons_enabled = true, component_separators = "|", section_separators = {left = "\238\130\180", right = "\238\130\182"}, globalstatus = true, disabled_filetypes = {}}, sections = {lualine_a = {"mode"}, lualine_b = {"branch", "diff", "diagnostics"}, lualine_c = {"lsp_progress"}, lualine_x = {"encoding", "filetype"}, lualine_y = {"progress"}, lualine_z = {"location"}}, tabline = {}, winbar = {lualine_a = {"filename"}}, inactive_winbar = {lualine_a = {"filename"}}, extensions = {}})
end
return {"nvim-lualine/lualine.nvim", dependencies = {"nvim-tree/nvim-web-devicons", "arkav/lualine-lsp-progress", lazy = true}, config = _1_}
