-- [nfnl] Compiled from fnl/plugins/care.fnl by https://github.com/Olical/nfnl, do not edit.
local nvim_autopairs = require("nvim-autopairs")
nvim_autopairs.setup()
local _local_1_ = require("care")
local setup = _local_1_["setup"]
local function _2_(entry, data)
  local _local_3_ = require("care.utils.lsp")
  local get_kind_name = _local_3_["get_kind_name"]
  local _local_4_ = require("care.presets.utils")
  local LabelEntries = _local_4_["LabelEntries"]
  local completion_item = entry["completion_item"]
  local _local_5_ = require("care.config").options.ui
  local type_icons = _local_5_["type_icons"]
  local entry_kind
  if (type(completion_item.kind) == "string") then
    entry_kind = completion_item.kind
  else
    entry_kind = get_kind_name(completion_item.kind)
  end
  return {{{completion_item.label}}, {{(" " .. (type_icons[entry_kind] or type_icons.Text) .. " " .. data.source_name .. ""), ("@care.type.%s"):format(entry_kind)}}}
end
local function _7_(body)
  local _local_8_ = require("luasnip")
  local lsp_expand = _local_8_["lsp_expand"]
  return lsp_expand(body)
end
setup({ui = {ghost_text = {position = "inline"}, menu = {max_height = 10, format_entry = _2_}}, alignment = {"left", "right"}, selection_behavior = "insert", confirm_behavior = "replace", sorting_direction = "away-from-cursor", sources = {lsp = {max_entries = 5, priority = 1}, cmp_buffer = {max_entries = 3}}, snippet_expansion = _7_})
vim.keymap.set("i", "<Cr>", "<Plug>(CareConfirm)")
vim.keymap.set("i", "<c-e>", "<Plug>(CareClose)")
vim.keymap.set("i", "<c-n>", "<Plug>(CareSelectNext)")
return vim.keymap.set("i", "<c-p>", "<Plug>(CareSelectPrev)")
