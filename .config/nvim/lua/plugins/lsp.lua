-- [nfnl] Compiled from fnl/plugins/lsp.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  vim.g.lsp_zero_extend_cmp = 0
  vim.g.lsp_zero_extend_lspconfig = 0
  return nil
end
local function _2_()
  local lsp_zero = require("lsp-zero")
  lsp_zero.extend_lspconfig()
  local function _3_(client, buf)
    lsp_zero.default_keymaps({buffer = buf, preserve_mappings = false})
    local mason_lspconfig = require("mason-lspconfig")
    local function _4_()
      local lspconfig = require("lspconfig")
      return lspconfig.lua_ls.setup(lsp_zero.nvim_lua_ls())
    end
    return mason_lspconfig.setup({ensure_installed = {"cssls", "eslint", "graphql", "html", "jsonnet_ls", "pyright", "rust_analyzer", "sqlls", "stylelint_lsp", "svelte", "tailwindcss", "tsserver", sumneko_lua = {Lua = {diagnostics = {globals = {"vim"}}, workspace = {checkThirdParty = false}, telemetry = {enable = false}}}}, handlers = {lsp_zero.default_setup, lua_ls = _4_}})
  end
  return lsp_zero.on_attach(_3_)
end
return {{"VonHeikemen/lsp-zero.nvim", branch = "dev-v3", lazy = true, init = _1_, config = false}, {"williamboman/mason.nvim", config = true, lazy = false}, {"neovim/nvim-lspconfig", cmd = {"LspInfo", "LspInstall", "LspStart"}, event = {"BufReadPre", "BufNewFile"}, dependencies = {"hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp", "williamboman/mason-lspconfig.nvim"}, config = _2_}}
