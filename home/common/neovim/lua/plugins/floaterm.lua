require("floaterm").setup({
	mappings = {
		term = function(buf)
			-- in terminal <C-q> to quick toggle
			vim.keymap.set({ "n", "t" }, "<C-q>", function()
				require("floaterm").toggle()
			end, { buffer = buf })
		end,
	},
})

local wk = require("which-key")

wk.add({
	{ "<leader>t", ":FloatermToggle<Cr>", desc = "Floaterm" },
})
