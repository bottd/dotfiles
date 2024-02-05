-- [nfnl] Compiled from fnl/plugins/oil.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  local oil = require("oil")
  return oil.setup({float = {padding = 17}})
end
local function _2_()
  local oil = require("oil")
  return oil.toggle_float()
end
local function _3_()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local current_dir = string.gsub(buf_name, "/[^/]+$", "")
  local oil = require("oil")
  return oil.toggle_float(current_dir)
end
return {"stevearc/oil.nvim", dependencies = {"nvim-tree/nvim-web-devicons"}, config = _1_, keys = {{"<C-n>", _2_, mode = "n", desc = "Oil - parent directory"}, {"<C-m>", _3_, mode = "n", desc = "Oil - current directory"}}}
