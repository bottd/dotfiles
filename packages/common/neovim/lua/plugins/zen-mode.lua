require("zen-mode").setup({
	plugins = {
		wezterm = {
			enabled = true,
		},
	},
})

vim.keymap.set("n", "<leader>wz", ":ZenMode<Cr>", { desc = "Zen Mode" })

require("which-key").add({
	{ "<leader>w", desc = "Window" },
})
