local nvim_autopairs = require("nvim-autopairs")
nvim_autopairs.setup()

local care = require("care")
care.setup({
	ui = {
		ghost_text = { position = "inline" },
		menu = { max_height = 10 },
		format_entry = function(entry, data)
			local components = require("care.presets.components")
			return {
				components.Label(entry, data, true),
				components.KindIcon(entry, "blended"),
			}
		end,
	},
	alignment = { "left", "right" },
	selection_behavior = "insert",
	confirm_behavior = "replace",
	sorting_direction = "away-from-cursor",
	sources = { lsp = { max_entries = 5, priority = 1 }, cmp_buffer = { max_entries = 3 } },
	snippet_expansion = function(body)
		local _local_3_ = require("luasnip")
		local lsp_expand = _local_3_["lsp_expand"]
		return lsp_expand(body)
	end,
})

vim.keymap.set("i", "<Cr>", "<Plug>(CareConfirm)")
vim.keymap.set("i", "<c-e>", "<Plug>(CareClose)")
vim.keymap.set("i", "<c-n>", "<Plug>(CareSelectNext)")
vim.keymap.set("i", "<c-p>", "<Plug>(CareSelectPrev)")
