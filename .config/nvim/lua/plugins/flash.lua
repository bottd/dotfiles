-- [nfnl] Compiled from fnl/plugins/flash.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local flash = require("flash")
  flash.setup({})
end
local function _1_()
  local flash = require("flash")
  return flash.jump()
end
vim.keymap.set({"n", "x", "o"}, "s", _1_, {desc = "Flash"})
local function _2_()
  local flash = require("flash")
  return flash.treesitter()
end
vim.keymap.set({"n", "o", "x"}, "S", _2_, {desc = "Flash Treesitter"})
local function _3_()
  local flash = require("flash")
  return flash.remote()
end
vim.keymap.set("o", "r", _3_, {desc = "Remote Flash"})
local function _4_()
  local flash = require("flash")
  return flash.treesitter_search()
end
vim.keymap.set({"o", "x"}, "R", _4_, {desc = "Treesitter Search"})
local function _5_()
  local flash = require("flash")
  return flash.toggle()
end
return vim.keymap.set("c", "<c-s>", _5_, {desc = "Toggle Flash Search"})
