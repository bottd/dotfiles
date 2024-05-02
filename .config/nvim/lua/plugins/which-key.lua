-- [nfnl] Compiled from fnl/plugins/which-key.fnl by https://github.com/Olical/nfnl, do not edit.
vim.o.timeout = true
vim.o.timeoutlen = 300
local which_key = require("which-key")
which_key.setup()
return which_key.register({e = "Evaluate [Conjure]", w = "Window", f = {name = "Find"}, l = "Log [Conjure]", n = "Neorg"}, {prefix = "<leader>"})
