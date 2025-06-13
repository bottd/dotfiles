require("oil").setup({ float = { padding = 17 } })

vim.keymap.set("n", "<C-n>", function()
	require("oil").toggle_float()
end, { desc = "Oil - parent directory" })

vim.keymap.set("n", "<C-m>", function()
	local buf_name = vim.api.nvim_buf_get_name(0)
	local current_dir = string.gsub(buf_name, "/[^/]+$", "")
	require("oil").toggle_float(current_dir)
end, { desc = "Oil - current directory" })
