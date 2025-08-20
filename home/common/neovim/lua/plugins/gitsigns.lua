local wk = require("which-key")
local gitsigns = require("gitsigns")

gitsigns.setup({})

wk.add({
	{ "ih", gitsigns.select_hunk, desc = "Select hunk", mode = { "o", "x" } },
	{ "<leader>h", group = "Git hunks" },
	{ "<leader>hs", gitsigns.stage_hunk, desc = "Stage hunk" },
	{ "<leader>hr", gitsigns.reset_hunk, desc = "Reset hunk" },
	{
		"<leader>hs",
		function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end,
		desc = "Stage hunk",
		mode = "v",
	},
	{
		"<leader>hr",
		function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end,
		desc = "Reset hunk",
		mode = "v",
	},
	{ "<leader>hS", gitsigns.stage_buffer, desc = "Stage buffer" },
	{ "<leader>hR", gitsigns.reset_buffer, desc = "Reset buffer" },
	{ "<leader>hp", gitsigns.preview_hunk, desc = "Preview hunk" },
	{ "<leader>hi", gitsigns.preview_hunk_inline, desc = "Preview hunk inline" },
	{
		"<leader>hb",
		function()
			gitsigns.blame_line({ full = true })
		end,
		desc = "Blame line",
	},
	{ "<leader>hd", gitsigns.diffthis, desc = "Diff this" },
	{
		"<leader>hD",
		function()
			gitsigns.diffthis("~")
		end,
		desc = "Diff this ~",
	},
	{
		"<leader>hQ",
		function()
			gitsigns.setqflist("all")
		end,
		desc = "All hunks to quickfix",
	},
	{ "<leader>hq", gitsigns.setqflist, desc = "Hunks to quickfix" },
})
