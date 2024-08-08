-- [nfnl] Compiled from fnl/plugins/conform.fnl by https://github.com/Olical/nfnl, do not edit.
local conform = require("conform")
return conform.setup({format_on_save = {timeout_ms = 500, lsp_fallback = true}, formatters_by_ft = {css = {"prettierd", "prettier"}, fennel = {"fnlfmt"}, html = {"prettierd", "prettier"}, javascript = {"prettierd", "prettier"}, json = {"prettierd", "prettier"}, lua = {"stylua"}, rust = {"rustfmt"}, svelte = {"prettierd", "prettier"}, toml = {"taplo"}, typescript = {"prettierd", "prettier"}, typescriptreact = {"prettierd", "prettier"}}})
