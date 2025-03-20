local telescope = require("telescope")
telescope.setup({
	pickers = {
		find_files = {
			layout_strategy = "vertical",
			additional_args = function()
				return { "--hidden" }
			end,
		},
		live_grep = {
			layout_strategy = "vertical",

			additional_args = function()
				return { "--hidden" }
			end,
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

telescope.load_extension("fzf")

vim.keymap.set("n", "<leader>fb", ":Telescope buffers<Cr>", { desc = "Find Buffer" })
vim.keymap.set("n", "<leader>fk", ":Telescope keymaps<Cr>", { desc = "Find Keymap" })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<Cr>", { desc = "Find Help" })

local wk = require("which-key")
wk.add({
	{ "<leader>f", desc = "Find" },
	{
		"<leader>ff",
		function()
			require("telescope.builtin").find_files({ hidden = true })
		end,
		desc = "Find Files",
	},
	{
		"<leader>fs",
		function()
			require("telescope.builtin").live_grep({ hidden = true })
		end,
		desc = "Find String",
	},
})
