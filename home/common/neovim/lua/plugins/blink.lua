require("cmp-npm").setup()

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer", "omni", "cmdline", "npm" },
		providers = {
			npm = {
				name = "npm",
				module = "blink.compat.source",
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
		kind_icons = {},
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
