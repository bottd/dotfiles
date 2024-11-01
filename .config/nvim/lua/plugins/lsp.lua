local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

vim.keymap.set("n", "gl", function()
	return vim.diagnostic.open_float()
end)

vim.keymap.set("n", "[d", function()
	return vim.diagnostic.goto_prev()
end)

vim.keymap.set("n", "]d", function()
	return vim.diagnostic.goto_next()
end)

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	callback = function(event)
		local opts = { buffer = event.buf }
		vim.keymap.set("n", "K", function()
			return vim.lsp.buf.hover()
		end, opts)
		vim.keymap.set("n", "gd", function()
			return vim.lsp.buf.definition()
		end, opts)
		vim.keymap.set("n", "gD", function()
			return vim.lsp.buf.declaration()
		end, opts)
		vim.keymap.set("n", "gi", function()
			return vim.lsp.buf.implementation()
		end, opts)
		vim.keymap.set("n", "go", function()
			return vim.lsp.buf.type_definition()
		end, opts)
		vim.keymap.set("n", "gr", function()
			return vim.lsp.buf.references()
		end, opts)
		vim.keymap.set("n", "gs", function()
			return vim.lsp.buf.signature_help()
		end, opts)
		vim.keymap.set("n", "<F2>", function()
			return vim.lsp.buf.rename()
		end, opts)
		return vim.keymap.set("n", "<F4>", function()
			return vim.lsp.buf.code_action()
		end, opts)
	end,
})

mason.setup({})
return mason_lspconfig.setup({
	ensure_installed = {
		"cssls",
		"eslint",
		"graphql",
		"html",
		"jsonnet_ls",
		"rust_analyzer",
		"sqlls",
		"lua_ls",
		"svelte",
		"tailwindcss",
		"ts_ls",
		"harper_ls",
	},
	handlers = {
		function(server_name)
			local server = (require("lspconfig"))[server_name]
			return server.setup({})
		end,
		harper_ls = function()
			local _local_16_ = require("lspconfig")
			local harper_ls = _local_16_["harper_ls"]
			return harper_ls.setup({
				filetypes = { "norg", "markdown" },
				settings = { ["harper-ls"] = { userDictPath = "~/.config/nvim/dict.txt" } },
			})
		end,
		rust_analyzer = function()
			local _local_18_ = require("lspconfig")
			local rust_analyzer = _local_18_["rust_analyzer"]
			return rust_analyzer.setup({
				cargo = { features = { "ssr" } },
				procMacro = { ignored = { leptos_macro = { "server" } } },
			})
		end,
		lua_ls = function()
			local _local_20_ = require("lspconfig")
			local lua_ls = _local_20_["lua_ls"]
			return lua_ls.setup({
				Lua = {
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					telemetry = {
						enable = false,
					},
				},
			})
		end,
	},
})
