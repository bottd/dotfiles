-- TODO: omnifunc integration for nvim-cmp to integrate LSP with completion
-- ** omnifunc from neovim lsp accessible here -> vim.lsp.omnifunc handler 
--
-- lsp-buf functions have a _sync variant for use when desired
-- Example:
-- Auto-format *.rs (rust) files prior to saving them
-- autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 1000)
require("mason").setup {
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
}

-- list of available servers:
-- https://github.com/williamboman/mason-lspconfig.nvim#default-configuration
require("mason-lspconfig").setup {
  ensure_installed = {
    "astro",
    "bashls",
    "clangd",
    "cssls",
    "cssmodules_ls",
    "eslint",
    "graphql",
    "html",
    "jsonnet_ls",
    "tsserver",
    "sumneko_lua",
    "prosemd_lsp",
    "spectral",
    "prismals",
    "pylsp",
    "rust_analyzer",
    "sqls",
    "svelte",
    "taplo",
    "tailwindcss",
    "lemminx",
    "yamlls"
  },
  automatic_installation = true
}

require('mason-tool-installer').setup {
  ensure_installed = {
    "node-debug2-adapter",
    "eslint_d",
    "markdownlint",
    "prettier",
    "rustfmt"
  },
  auto_update = true,
  run_on_start = true
}
