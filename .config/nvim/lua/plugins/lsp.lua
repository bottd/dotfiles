-- [nfnl] Compiled from fnl/plugins/lsp.fnl by https://github.com/Olical/nfnl, do not edit.
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local function _1_()
  return vim.diagnostic.open_float()
end
vim.keymap.set("n", "gl", _1_)
local function _2_()
  return vim.diagnostic.goto_prev()
end
vim.keymap.set("n", "[d", _2_)
local function _3_()
  return vim.diagnostic.goto_next()
end
vim.keymap.set("n", "]d", _3_)
local function _4_(event)
  local opts = {buffer = event.buf}
  local function _5_()
    return vim.lsp.buf.hover()
  end
  vim.keymap.set("n", "K", _5_, opts)
  local function _6_()
    return vim.lsp.buf.definition()
  end
  vim.keymap.set("n", "gd", _6_, opts)
  local function _7_()
    return vim.lsp.buf.declaration()
  end
  vim.keymap.set("n", "gD", _7_, opts)
  local function _8_()
    return vim.lsp.buf.implementation()
  end
  vim.keymap.set("n", "gi", _8_, opts)
  local function _9_()
    return vim.lsp.buf.type_definition()
  end
  vim.keymap.set("n", "go", _9_, opts)
  local function _10_()
    return vim.lsp.buf.references()
  end
  vim.keymap.set("n", "gr", _10_, opts)
  local function _11_()
    return vim.lsp.buf.signature_help()
  end
  vim.keymap.set("n", "gs", _11_, opts)
  local function _12_()
    return vim.lsp.buf.rename()
  end
  vim.keymap.set("n", "<F2>", _12_, opts)
  local function _13_()
    return vim.lsp.buf.code_action()
  end
  return vim.keymap.set("n", "<F4>", _13_, opts)
end
vim.api.nvim_create_autocmd("LspAttach", {desc = "LSP Actions", callback = _4_})
mason.setup({})
local function _14_(server_name)
  local server = (require("lspconfig"))[server_name]
  return server.setup({})
end
local function _15_()
  local _local_16_ = require("lspconfig")
  local harper_ls = _local_16_["harper_ls"]
  return harper_ls.setup({filetypes = {"norg", "markdown", "rust", "typescript", "typescriptreact", "javascript", "python", "go", "c", "cpp", "ruby", "swift", "csharp", "toml", "lua", "gitcommit", "java", "html"}, settings = {["harper-ls"] = {userDictPath = "~/.config/nvim/dict.txt"}}})
end
local function _17_()
  local _local_18_ = require("lspconfig")
  local rust_analyzer = _local_18_["rust_analyzer"]
  return rust_analyzer.setup({cargo = {features = {"ssr"}}, procMacro = {ignored = {leptos_macro = {"server"}}}})
end
local function _19_()
  local _local_20_ = require("lspconfig")
  local lua_ls = _local_20_["lua_ls"]
  return lua_ls.setup({Lua = {diagnostics = {globals = {"vim"}}, workspace = {checkThirdParty = false}, telemetry = {enable = false}}})
end
return mason_lspconfig.setup({ensure_installed = {"cssls", "eslint", "graphql", "html", "jsonnet_ls", "pyright", "rust_analyzer", "sqlls", "stylelint_lsp", "lua_ls", "svelte", "tailwindcss", "ts_ls", "harper_ls"}, handlers = {_14_, harper_ls = _15_, rust_analyzer = _17_, lua_ls = _19_}})
