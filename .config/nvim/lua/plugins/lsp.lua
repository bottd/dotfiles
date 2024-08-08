-- [nfnl] Compiled from fnl/plugins/lsp.fnl by https://github.com/Olical/nfnl, do not edit.
vim.g.lsp_zero_extend_cmp = 0
vim.g.lsp_zero_extend_lspconfig = 0
do
  local lsp_zero = require("lsp-zero")
  lsp_zero.extend_lspconfig()
  local function _1_(client, buf)
    return lsp_zero.default_keymaps({buffer = buf, preserve_mappings = false})
  end
  lsp_zero.on_attach(_1_)
end
do
  local mason = require("mason")
  mason.setup({})
end
local lsp_zero = require("lsp-zero")
local mason_lspconfig = require("mason-lspconfig")
return mason_lspconfig.setup({automatic_installation = true, ensure_installed = {"cssls", "eslint", "graphql", "html", "jsonnet_ls", "pyright", rust_analyzer = {cargo = {features = {"ssr"}}, procMacro = {ignored = {leptos_macro = {"server"}}}}, [8] = "sqlls", [9] = "stylelint_lsp", lua_ls = {Lua = {diagnostics = {globals = {"vim"}}, workspace = {checkThirdParty = false}, telemetry = {enable = false}}}, [10] = "svelte", [11] = "tailwindcss", [12] = "tsserver", [13] = "fennel_ls"}, handlers = {lsp_zero.default_setup}})
