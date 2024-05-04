(set vim.g.lsp_zero_extend_cmp 0)
(set vim.g.lsp_zero_extend_lspconfig 0)

(let [lsp_zero (require :lsp-zero)]
        (lsp_zero.extend_lspconfig)
        (lsp_zero.on_attach (fn [client buf]
          ;see :help lsp-zero-keybindings
          ;to learn the available actions
          (lsp_zero.default_keymaps {:buffer buf :preserve_mappings false }))))

(let [mason (require :mason)]
  (mason.setup {}))

(let [
      lsp_zero (require :lsp-zero)
      mason_lspconfig (require :mason-lspconfig)]
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
            :lua_ls {
              :Lua {
                :diagnostics { :globals [:vim] }
                :workspace { :checkThirdParty false }
                :telemetry { :enable false }
              }
            }
            10 :svelte
            11 :tailwindcss
            12 :tsserver
            13 :fennel_ls
        }
        :handlers { 1 lsp_zero.default_setup}
      }
    ))
