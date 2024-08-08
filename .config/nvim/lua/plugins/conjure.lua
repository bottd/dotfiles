-- [nfnl] Compiled from fnl/plugins/conjure.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local cmp = require("cmp")
  local config = cmp.get_config()
  table.insert(config.sources, {name = "buffer", option = {sources = {{name = "conjure"}}}})
  cmp.setup(config)
end
require("conjure.main").main()
require("conjure.mapping")["on-filetype"]()
local which_key = require("which-key")
return which_key.add({{"<leader>e", desc = "Evaluate [Conjure]"}, {"<leader>l", desc = "Log [Conjure]"}})
