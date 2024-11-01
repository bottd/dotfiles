local indentscope = require("mini.indentscope")
indentscope.setup({
	symbol = "│",
	options = { try_as_border = true },
	animation = indentscope.gen_animation.linear({ easing = "out", duration = 20, unit = "total" }),
})

local ibl = require("ibl")
ibl.setup({ indent = { char = "│" }, scope = { enabled = false } })
