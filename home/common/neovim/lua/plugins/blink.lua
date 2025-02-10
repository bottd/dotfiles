require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer", "codecompanion", "copilot" },
		providers = {
			codecompanion = {
				name = "CodeCompanion",
				module = "codecompanion.providers.completion.blink",
				enabled = true,
			},
			copilot = {
				name = "copilot",
				module = "blink-copilot",
			},
		},
	},
	completion = {
		keyword = {
			range = "prefix",
		},
		list = {
			selection = {
				preselect = true,
				auto_insert = true,
			},
			cycle = {
				from_bottom = true,
				from_top = true,
			},
		},
		accept = {
			create_undo_point = true,
			auto_brackets = {
				enabled = true,
				kind_resolution = {
					enabled = true,
				},
				semantic_token_resolution = {
					enabled = true,
				},
			},
		},

		menu = {
			border = "padded",
			draw = {
				padding = 1,
				gap = 1,
				treesitter = { "lsp" },
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "source_name" },
				},
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 500,
			window = {
				border = "padded",
				scrollbar = true,
			},
		},
		ghost_text = {
			enabled = true,
		},
	},
	appearance = {
		kind_icons = {
			Copilot = "",
		},
	},
})
