local wk = require("which-key")
local gitsigns = require("gitsigns")
gitsigns.setup({})
local function _1_()
	return gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end
local function _2_()
	return gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end
local function _3_()
	return gitsigns.blame_line({ full = true })
end
local function _4_()
	return gitsigns.diffthis("~")
end
local function _5_()
	return gitsigns.setqflist("all")
end
return wk.add({
	{ "ih", gitsigns.select_hunk, desc = "Select hunk", mode = { "o", "x" } },
	{ "<leader>h", group = "Git hunks" },
	{ "<leader>hs", gitsigns.stage_hunk, desc = "Stage hunk" },
	{ "<leader>hr", gitsigns.reset_hunk, desc = "Reset hunk" },
	{ "<leader>hs", _1_, desc = "Stage hunk", mode = "v" },
	{ "<leader>hr", _2_, desc = "Reset hunk", mode = "v" },
	{ "<leader>hS", gitsigns.stage_buffer, desc = "Stage buffer" },
	{ "<leader>hR", gitsigns.reset_buffer, desc = "Reset buffer" },
	{ "<leader>hp", gitsigns.preview_hunk, desc = "Preview hunk" },
	{ "<leader>hi", gitsigns.preview_hunk_inline, desc = "Preview hunk inline" },
	{ "<leader>hb", _3_, desc = "Blame line" },
	{ "<leader>hd", gitsigns.diffthis, desc = "Diff this" },
	{ "<leader>hD", _4_, desc = "Diff this ~" },
	{ "<leader>hQ", _5_, desc = "All hunks to quickfix" },
	{ "<leader>hq", gitsigns.setqflist, desc = "Hunks to quickfix" },
})
