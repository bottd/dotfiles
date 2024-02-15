-- [nfnl] Compiled from fnl/zk.fnl by https://github.com/Olical/nfnl, do not edit.
local an = require("alphanum")
local dirman = ((require("neorg")).modules).get_module("core.dirman")
local function get_sorted_zettel()
  local files = dirman.get_norg_files("zettel")
  table.sort(files, an.alphanum_compare)
  do
    local ed_width = vim.fn.winwidth("%")
    local ed_height = vim.fn.winwidth("%")
    local win_width = math.floor((ed_width * 0.6))
    local win_height = math.floor((ed_height * 0.8))
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(bufnr, true, {width = win_width, height = win_height, row = ((ed_height - win_height) / 2), col = ((ed_width - win_width) / 2), relative = "editor", border = "rounded", title = "Zettels", title_pos = "center"})
  end
  return vim.api.nvim_command(":Neorg journal today")
end
return print(get_sorted_zettel())
