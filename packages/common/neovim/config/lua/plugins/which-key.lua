vim.o.timeout = true
vim.o.timeoutlen = 300
local which_key = require("which-key")
return which_key.add({
	{
		"<C-w><space>",
		function()
			return which_key.show({ keys = "<C-w>", loop = true })
		end,
	},
	{
		"<leader>w",
		group = "windows",
		proxy = "<c-w>",
		expand = function()
			return require("which-key.extras").expand.win()
		end,
	},
})
