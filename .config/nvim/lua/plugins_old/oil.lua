-- [nfnl] Compiled from fnl/plugins/oil.fnl by https://github.com/Olical/nfnl, do not edit.
local oil = require("oil")
oil.setup({float = {padding = 17}})
local function _1_()
  local oil0 = require("oil")
  return oil0.toggle_float()
end
vim.keymap.set("n", "<C-n>", _1_, {desc = "Oil - parent directory"})
local function _2_()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local current_dir = string.gsub(buf_name, "/[^/]+$", "")
  local oil0 = require("oil")
  return oil0.toggle_float(current_dir)
end
vim.keymap.set("n", "<C-m>", _2_, {desc = "Oil - current directory"})
local function _3_()
  local oil0 = require("oil")
  return oil0.select({vertical = true})
end
return vim.keymap.set("n", "<C-v>", _3_, {desc = "Oil - select vsplit", buffer = "oil"})
