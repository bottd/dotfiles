-- [nfnl] Compiled from fnl/plugins/nvim-lspconfig.fnl by https://github.com/Olical/nfnl, do not edit.
vim.g.lsp_zero_extend_cmp = 0
vim.g.lsp_zero_extend_lspconfig = 0
local lsp_zero = require("lsp-zero")
lsp_zero.extend_lspconfig()
local function _1_(client, buf)
  lsp_zero.default_keymaps({buffer = buf, preserve_mappings = false})
  local mason_lspconfig = require("mason-lspconfig")
  local function _2_()
    local lspconfig = require("lspconfig")
    return lspconfig.lua_ls.setup(lsp_zero.nvim_lua_ls())
  end
  return mason_lspconfig.setup({ensure_installed = {"cssls", "eslint", "graphql", "html", "jsonnet_ls", "pyright", "rust_analyzer", "sqlls", "stylelint_lsp", "svelte", "tailwindcss", "tsserver", sumneko_lua = {Lua = {diagnostics = {globals = {"vim"}}, workspace = {checkThirdParty = false}, telemetry = {enable = false}}}}, handlers = {lsp_zero.default_setup, lua_ls = _2_}})
end
return lsp_zero.on_attach(_1_)
