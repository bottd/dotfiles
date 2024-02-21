-- [nfnl] Compiled from fnl/zk.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("alphanum")
local an_srt = _local_1_["an_srt"]
local function path_to_name(path)
  return path:match("^.+/(.+)$")
end
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
  local file_names
  do
    local tbl_17_auto = {}
    local i_18_auto = #tbl_17_auto
    for k, v in pairs(files) do
      local val_19_auto = path_to_name(v)
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    file_names = tbl_17_auto
  end
  local zfiles = an_srt(file_names)
  local xfiles
  do
    local tbl_17_auto = {}
    local i_18_auto = #tbl_17_auto
    for k, v in pairs(zfiles) do
      local val_19_auto = v.id
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    xfiles = tbl_17_auto
  end
  local ed_width = vim.fn.winwidth("%")
  local ed_height = vim.fn.winwidth("%")
  local win_width = math.floor((ed_width * 0.6))
  local win_height = math.floor((ed_height * 0.8))
  local buf = vim.api.nvim_create_buf(true, true)
  vim.cmd("vsplit")
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, xfiles)
  vim.api.nvim_buf_set_name(buf, "zettels")
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
  return vim.api.nvim_buf_set_keymap(buf, "n", "<Cr>", "", {callback = open_zettel})
end
return {get_sorted_zettel = get_sorted_zettel}
