require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer", "codecompanion", "copilot", "omni", "cmdline" },
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
	signature = { enabled = true },
	completion = {
		keyword = {
			range = "prefix",
		},

		list = {
			selection = {
				preselect = true,
				auto_insert = true,
			},
		},

		menu = {
			draw = {
				treesitter = { "lsp" },
				columns = {
					{ "source_name" },
					{ "kind_icon" },
					{ "kind" },
					{ "label", "label_description", gap = 1 },
				},
			},
		},
		documentation = {
			auto_show = true,
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
	fuzzy = {
		sorts = {
			"exact",
			"score",
			"sort_text",
		},
	},
	term = {
		enabled = true,
	},
})
