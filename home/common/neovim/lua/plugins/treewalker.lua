require("treewalker").setup({})

vim.keymap.set("n", "<leader>t", function()
	require("which-key").show({
		keys = "<leader>t",
		group = "Treewalker",
		loop = true,
	})
end, { desc = "Treewalker" })

vim.keymap.set("n", "<leader>th", ":Treewalker Left<Cr>", { desc = "Move Left" })
vim.keymap.set("n", "<leader>tj", ":Treewalker Down<Cr>", { desc = "Move Down" })
vim.keymap.set("n", "<leader>tk", ":Treewalker Up<Cr>", { desc = "Move Up" })
vim.keymap.set("n", "<leader>tl", ":Treewalker Right<Cr>", { desc = "Move Right" })

vim.keymap.set("n", "<leader>tH", ":Treewalker SwapLeft<Cr>", { desc = "Swap Left" })
vim.keymap.set("n", "<leader>tJ", ":Treewalker SwapDown<Cr>", { desc = "Swap Down" })
vim.keymap.set("n", "<leader>tK", ":Treewalker SwapUp<Cr>", { desc = "Swap Up" })
vim.keymap.set("n", "<leader>tL", ":Treewalker SwapRight<Cr>", { desc = "Swap Right" })
