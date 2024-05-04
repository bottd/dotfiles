-- [nfnl] Compiled from fnl/plugins/conjure.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local cmp = require("cmp")
  local config = cmp.get_config()
  table.insert(config.sources, {name = "buffer", option = {sources = {{name = "conjure"}}}})
  cmp.setup(config)
end
do end (require("conjure.main")).main()
return (require("conjure.mapping"))["on-filetype"]()
