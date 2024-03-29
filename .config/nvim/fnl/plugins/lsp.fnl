{
  1 {
    1 :VonHeikemen/lsp-zero.nvim
    :branch "dev-v3"
    :lazy true
    :config false
    :init (fn []
      (set vim.g.lsp_zero_extend_cmp 0)
      (set vim.g.lsp_zero_extend_lspconfig 0)
    )
  }
  2 {
    1 :williamboman/mason.nvim
    :lazy false
    :config true
  }
  3 {
    1 :neovim/nvim-lspconfig
    :cmd [:LspInfo :LspInstall :LspStart]
    :event [:BufReadPre :BufNewFile]
    :dependencies [
      :hrsh7th/nvim-cmp
      :hrsh7th/cmp-nvim-lsp
      :williamboman/mason-lspconfig.nvim
    ]
    :config (fn []
      (let [lsp_zero (require :lsp-zero)]
        (lsp_zero.extend_lspconfig)
        (lsp_zero.on_attach (fn [client buf]
          ;see :help lsp-zero-keybindings
          ;to learn the available actions
          (lsp_zero.default_keymaps {:buffer buf :preserve_mappings false })
          (let [mason_lspconfig (require :mason-lspconfig)]
            (mason_lspconfig.setup {
              :ensure_installed {
                1 :cssls
                2 :eslint
                3 :graphql
                4 :html
                5 :jsonnet_ls
                6 :pyright
                7 :rust_analyzer
                8 :sqlls
                9 :stylelint_lsp
                :sumneko_lua {
                  :Lua {
                    :diagnostics { :globals [:vim] }
                    :workspace { :checkThirdParty false }
                    :telemetry { :enable false }
                  }
                }
                10 :svelte
                11 :tailwindcss
                12 :tsserver
            }
            :handlers {
              1 lsp_zero.default_setup
              :lua_ls (fn []
                ;(Optional) Configure lua language server for neovim
                (let [lspconfig (require :lspconfig)]
                  (lspconfig.lua_ls.setup (lsp_zero.nvim_lua_ls))
                ))
            }
          }
        )
      )
    ))))}}
