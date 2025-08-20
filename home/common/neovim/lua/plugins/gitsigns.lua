local wk = require("which-key")

require("gitsigns").setup({})

wk.add({
	{ "<leader>gb", ":Gitsigns blame", desc = "Toggle Git Blame" },
})
