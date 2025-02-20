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

local servers = {
	cssls = {},
	eslint = {},
	graphql = {},
	html = {},
	-- sqlls = {},
	svelte = {},
	tailwindcss = {},
	ts_ls = {},
	harper_ls = {
		filetypes = { "norg", "markdown" },
		settings = { ["harper-ls"] = { userDictPath = "~/.config/nvim/dict.txt" } },
	},
	rust_analyzer = {
		cargo = { features = { "ssr" } },
		procMacro = { ignored = { leptos_macro = { "server" } } },
	},
	lua_ls = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = {
				enable = false,
			},
		},
	},
}

local lspconfig = require("lspconfig")
for server, config in pairs(servers) do
	-- passing config.capabilities to blink.cmp merges with the capabilities in your
	-- `opts[server].capabilities, if you've defined it
	config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
	lspconfig[server].setup(config)
end
