require("conform").setup({
	format_on_save = { timeout_ms = 500, lsp_fallback = true },
	formatters_by_ft = {
		["*"] = { "treefmt" },
		css = { "prettierd", "prettier" },
		html = { "prettierd", "prettier" },
		javascript = { "prettierd", "prettier" },
		json = { "prettierd", "prettier" },
		lua = { "stylua" },
		rust = { "rustfmt" },
		svelte = { "prettierd", "prettier" },
		toml = { "taplo" },
		typescript = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
	},
	formatters = {
		treefmt = {
			command = "treefmt",
			args = { "--stdin", "$FILENAME" },
			stdin = true,
			cwd = require("conform.util").root_file({ "treefmt.toml" }),
			condition = function(self, ctx)
				return vim.fs.find({ "treefmt.toml", "flake.nix" }, {
					path = ctx.filename,
					upward = true
				})[1] ~= nil
			end,
		},
	},
})
