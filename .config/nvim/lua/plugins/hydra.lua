-- [nfnl] Compiled from fnl/plugins/hydra.fnl by https://github.com/Olical/nfnl, do not edit.
local hydra = require("hydra")
local splits = require("smart-splits")
local cmd = require("hydra.keymap-util").cmd
local pcmd = require("hydra.keymap-util").pcmd
local function _1_()
  return splits.resize_left(2)
end
local function _2_()
  return splits.resize_down(2)
end
local function _3_()
  return splits.resize_up(2)
end
local function _4_()
  return splits.resize_right(2)
end
local function _5_()
  return vim.fn.termopen()
end
return hydra({name = "Windows", hint = window_hint, config = {invoke_on_body = true, hint = {float_opts = {border = "rounded"}, offset = -1}}, mode = "n", body = "<C-w>", heads = {{"h", "<C-w>h"}, {"j", "<C-w>j"}, {"k", pcmd("wincmd k", "E11", "close")}, {"l", "<C-w>l"}, {"H", cmd("WinShift left")}, {"J", cmd("WinShift down")}, {"K", cmd("WinShift up")}, {"L", cmd("WinShift right")}, {"<C-h>", _1_}, {"<C-j>", _2_}, {"<C-k>", _3_}, {"<C-l>", _4_}, {"=", "<C-w>=", {desc = "equalize"}}, {"s", pcmd("split", "E36")}, {"<C-s>", pcmd("split", "E36"), {desc = false}}, {"v", pcmd("vsplit", "E36")}, {"<C-v>", pcmd("vsplit", "E36"), {desc = false}}, {"w", "<C-w>w", {exit = true, desc = false}}, {"<C-w>", "<C-w>w", {exit = true, desc = false}}, {"z", cmd("WindowsMaximaze"), {exit = true, desc = "maximize"}}, {"<C-z>", cmd("WindowsMaximaze"), {exit = true, desc = false}}, {"o", "<C-w>o", {exit = true, desc = "remain only"}}, {"<C-o>", "<C-w>o", {exit = true, desc = false}}, {"b", choose_buffer, {exit = true, desc = "choose buffer"}}, {"t", _5_}, {"c", pcmd("close", "E444")}, {"q", pcmd("close", "E444"), {desc = "close window"}}, {"<C-c>", pcmd("close", "E444"), {desc = false}}, {"<C-q>", pcmd("close", "E444"), {desc = false}}, {"<Esc>", nil, {exit = true, desc = false}}}})
