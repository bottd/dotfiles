-- [nfnl] Compiled from fnl/plugins/spectre.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  return (require("spectre")).toggle()
end
local function _2_()
  return (require("spectre")).open_visual({select_word = true})
end
local function _3_()
  return (require("spectre")).open_visual()
end
local function _4_()
  return (require("spectre")).open_file_search({select_word = true})
end
return {"nvim-pack/nvim-spectre", keys = {{"<leader>S<Cr>", _1_, mode = "n", desc = "Toggle Spectre"}, {"<leader>sw<Cr>", _2_, mode = "n", desc = "Search current word"}, {"<leader>sw<Cr>", _3_, mode = "v", desc = "Search current word"}, {"<leader>sp<Cr>", _4_, mode = "n", desc = "Search on current file"}}}
