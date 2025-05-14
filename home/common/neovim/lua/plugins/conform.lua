require("conform").setup({
	format_on_save = { timeout_ms = 500, lsp_fallback = true },
	formatters_by_ft = {
		css = { "prettierd", "prettier" },
		html = { "prettierd", "prettier" },
		javascript = { "prettierd", "prettier" },
		json = { "prettierd", "prettier" },
		lua = { "stylua" },
		-- TODO: treefmt in conform
		-- nix = { "treefmt" },
		rust = { "rustfmt" },
		svelte = { "prettierd", "prettier" },
		toml = { "taplo" },
		typescript = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
	},
})
