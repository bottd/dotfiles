-- [nfnl] Compiled from fnl/plugins/treesitter.fnl by https://github.com/Olical/nfnl, do not edit.
local treesitter_context = require("treesitter-context")
treesitter_context.setup()
local nvim_ts_autotag = require("nvim-ts-autotag")
return nvim_ts_autotag.setup()
