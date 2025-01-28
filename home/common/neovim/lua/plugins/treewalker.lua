require("treewalker").setup()

vim.keymap.set("n", "<leader>th", ":Treewalker Left", { desc = "Move Left" })
vim.keymap.set("n", "<leader>tj", ":Treewalker Down", { desc = "Move Down" })
vim.keymap.set("n", "<leader>tk", ":Treewalker Up", { desc = "Move Up" })
vim.keymap.set("n", "<leader>tl", ":Treewalker Right", { desc = "Move Right" })

vim.keymap.set("n", "<leader>tk", ":Treewalker SwapLeft", { desc = "Swap Left" })
vim.keymap.set("n", "<leader>tk", ":Treewalker SwapDown", { desc = "Swap Down" })
vim.keymap.set("n", "<leader>tk", ":Treewalker SwapUp", { desc = "Swap Up" })
vim.keymap.set("n", "<leader>tk", ":Treewalker SwapRight", { desc = "Swap Right" })

require("which-key").show({
	keys = "<leader>t",
	group = "Treewalker",
	loop = true,
})
