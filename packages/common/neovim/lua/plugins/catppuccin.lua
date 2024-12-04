require("catppuccin").setup({
	background = { light = "latte", dark = "mocha" },
	flavor = "auto",
	custom_highlights = function(colors)
		return { MiniIndentscopeSymbol = { fg = colors.lavender } }
	end,
})
