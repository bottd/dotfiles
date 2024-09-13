-- [nfnl] Compiled from fnl/plugins/lsp.fnl by https://github.com/Olical/nfnl, do not edit.
local lsp_zero = require("lsp-zero")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local function lsp_attach(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr, preserve_mappings = false})
  return vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>'", {desc = "Code Action"})
end
mason.setup({})
local function _1_(server_name)
  local server = require("lspconfig")[server_name]
  return server.setup({})
end
local function _2_()
  local _local_3_ = require("lspconfig")
  local harper_ls = _local_3_["harper_ls"]
  return harper_ls.setup({filetypes = {"norg", "markdown", "rust", "typescript", "typescriptreact", "javascript", "python", "go", "c", "cpp", "ruby", "swift", "csharp", "toml", "lua", "gitcommit", "java", "html"}, settings = {["harper-ls"] = {userDictPath = "~/.config/nvim/dict.txt"}}})
end
local function _4_()
  local _local_5_ = require("lspconfig")
  local rust_analyzer = _local_5_["rust_analyzer"]
  return rust_analyzer.setup({cargo = {features = {"ssr"}}, procMacro = {ignored = {leptos_macro = {"server"}}}})
end
local function _6_()
  local _local_7_ = require("lspconfig")
  local lua_ls = _local_7_["lua_ls"]
  return lua_ls.setup({Lua = {diagnostics = {globals = {"vim"}}, workspace = {checkThirdParty = false}, telemetry = {enable = false}}})
end
return mason_lspconfig.setup({ensure_installed = {"cssls", "eslint", "graphql", "html", "jsonnet_ls", "pyright", "rust_analyzer", "sqlls", "stylelint_lsp", "lua_ls", "svelte", "tailwindcss", "ts_ls", "harper_ls"}, handlers = {_1_, harper_ls = _2_, rust_analyzer = _4_, lua_ls = _6_}})
