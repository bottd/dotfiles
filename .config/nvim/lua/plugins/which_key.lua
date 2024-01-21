-- [nfnl] Compiled from fnl/plugins/which_key.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  vim.o.timeout = true
  vim.o.timeoutlen = 300
  local which_key = require("which-key")
  which_key.setup()
  return which_key.register({e = "Evaluate [Conjure]", f = {name = "Find"}, l = "Log [Conjure]", n = "Neorg"}, {prefix = "<leader>"})
end
return {"folke/which-key.nvim", config = _1_}
