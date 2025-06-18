require("catppuccin").setup({
	background = { light = "latte", dark = "mocha" },
	flavor = "auto",
	custom_highlights = function(colors)
		return { MiniIndentscopeSymbol = { fg = colors.lavender } }
	end,
	integrations = {
		blink_cmp = true,
		cmp = false,
		headlines = true,
		indent_blankline = {
			enabled = true,
			colored_indent_levels = true,
		},
		which_key = true,
	},
})
