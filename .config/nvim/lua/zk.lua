-- [nfnl] Compiled from fnl/zk.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("alphanum")
local an_compare = _local_1_["an-compare"]
local function open_zettel()
  local neorg = require("neorg")
  local dirman = neorg.modules.get_module("core.dirman")
  local line = vim.api.nvim_get_current_line()
  return dirman.open_file("zettel", line)
end
local function get_sorted_zettel()
  local neorg = require("neorg")
  local dirman = neorg.modules.get_module("core.dirman")
  local files = dirman.get_norg_files("zettel")
  table.sort(files, an_compare)
  local ed_width = vim.fn.winwidth("%")
  local ed_height = vim.fn.winwidth("%")
  local win_width = math.floor((ed_width * 0.6))
  local win_height = math.floor((ed_height * 0.8))
  local buf = vim.api.nvim_create_buf(true, true)
  vim.cmd("vsplit")
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, files)
  vim.api.nvim_buf_set_name(buf, "zettels")
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
  return vim.api.nvim_buf_set_keymap(buf, "n", "<Cr>", "", {callback = open_zettel})
end
return {get_sorted_zettel = get_sorted_zettel}
