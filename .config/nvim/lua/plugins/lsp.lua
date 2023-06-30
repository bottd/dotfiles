return {
  'folke/neodev.nvim',
  'mfussenegger/nvim-dap',
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('config/lsp')
    end,
    dependencies = {
      {
        'williamboman/mason.nvim',
        config = function()
          require("mason").setup {
            ui = {
              icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
              }
            }
          }
        end
      },
      {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        config = function()
          require('mason-tool-installer').setup {
            ensure_installed = {
              "node-debug2-adapter",
              "eslint_d",
              "markdownlint",
              "prettier"
            },
            auto_update = true,
            run_on_start = true
          }
        end
      },
      'williamboman/mason-lspconfig.nvim'
    }
  },
}
