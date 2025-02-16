require("treewalker").setup({})
local wk = require("which-key")

wk.add({
	{
		"<leader>t",
		function()
			wk.show({
				keys = "<leader>t",
				loop = true,
			})
		end,
		group = "Treewalker",
		icon = "󰹩",
	},
	{ "<leader>th", ":Treewalker Left<Cr>", desc = "Move Left" },
	{ "<leader>th", ":Treewalker Left<Cr>", desc = "Move Left" },
	{ "<leader>tj", ":Treewalker Down<Cr>", desc = "Move Down" },
	{ "<leader>tk", ":Treewalker Up<Cr>", desc = "Move Up" },
	{ "<leader>tl", ":Treewalker Right<Cr>", desc = "Move Right" },
	{ "<leader>tH", ":Treewalker SwapLeft<Cr>", desc = "Swap Left" },
	{ "<leader>tJ", ":Treewalker SwapDown<Cr>", desc = "Swap Down" },
	{ "<leader>tK", ":Treewalker SwapUp<Cr>", desc = "Swap Up" },
	{ "<leader>tL", ":Treewalker SwapRight<Cr>", desc = "Swap Right" },
})
