-- [nfnl] Compiled from fnl/plugins/which-key.fnl by https://github.com/Olical/nfnl, do not edit.
vim.o.timeout = true
vim.o.timeoutlen = 300
local which_key = require("which-key")
local splits = require("smart-splits")
local function _1_()
  return which_key.show({keys = "<C-w>", loop = true})
end
local function _2_()
  return require("which-key.extras")(__fnl_global___2eexpand_2ewin)
end
return which_key.add({{"<C-w><space>", _1_}, {"<leader>w", group = "windows", proxy = "<c-w>", expand = _2_}})
