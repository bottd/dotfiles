-- [nfnl] Compiled from fnl/plugins/indent-lines.fnl by https://github.com/Olical/nfnl, do not edit.
local indentscope = require("mini.indentscope")
indentscope.setup({symbol = "\226\148\130", options = {try_as_border = true}, animation = indentscope.gen_animation.linear({easing = "out", duration = 20, unit = "total"})})
local ibl = require("ibl")
return ibl.setup({indent = {char = "\226\148\130"}, scope = {enabled = false}})
