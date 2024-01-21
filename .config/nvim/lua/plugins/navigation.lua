-- [nfnl] Compiled from fnl/plugins/navigation.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  local flash = require("flash")
  return flash.jump()
end
local function _2_()
  local flash = require("flash")
  return flash.treesitter()
end
local function _3_()
  local flash = require("flash")
  return flash.remote()
end
local function _4_()
  local flash = require("flash")
  return flash.treesitter_search()
end
local function _5_()
  local flash = require("flash")
  return flash.toggle()
end
return {"folke/flash.nvim", event = "VeryLazy", opts = {}, keys = {{"s", _1_, mode = {"n", "x", "o"}, desc = "Flash"}, {"S", _2_, mode = {"n", "o", "x"}, desc = "Flash Treesitter"}, {"r", _3_, mode = "o", desc = "Remote Flash"}, {"R", _4_, mode = {"o", "x"}, desc = "Treesitter Search"}, {"<c-s>", _5_, mode = {"c"}, desc = "Toggle Flash Search"}}}
