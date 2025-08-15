vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Override vim.print to suppress version object output
local original_print = vim.print
vim.print = function(...)
	local args = { ... }
	-- Check if any argument looks like a version object
	for _, arg in ipairs(args) do
		if type(arg) == "table" and arg.major and arg.minor and arg.patch then
			return -- Suppress version object output
		end
	end
	return original_print(...)
end
vim.keymap.set("n", "<Leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("t", "<Esc>", "<C-\\\\><C-n>")
