(local lsp_zero (require :lsp-zero))
(local mason (require :mason))
(local mason_lspconfig (require :mason-lspconfig))
;see :help lsp-zero-keybindings
;to learn the available actions

(fn lsp_attach [client bufnr]
  (lsp_zero.default_keymaps {:buffer bufnr :preserve_mappings false})
  (vim.keymap.set :n :<leader>ca "<cmd>lua vim.lsp.buf.code_action()<cr>'"
                  {:desc "Code Action"}))

(mason.setup {})

(mason_lspconfig.setup {:ensure_installed [:cssls
                                           :eslint
                                           :graphql
                                           :html
                                           :jsonnet_ls
                                           :pyright
                                           :rust_analyzer
                                           :sqlls
                                           :stylelint_lsp
                                           :lua_ls
                                           :svelte
                                           :tailwindcss
                                           :ts_ls
                                           ;:fennel_language_server
                                           :harper_ls]
                        :handlers {1 (fn [server_name]
                                       (local server
                                              (. (require :lspconfig)
                                                 server_name))
                                       (server.setup {}))
                                   ; TODO user dict not appearing to work currently
                                   :harper_ls (fn []
                                                (local {: harper_ls}
                                                       (require :lspconfig))
                                                (harper_ls.setup {:filetypes [:norg
                                                                              :markdown
                                                                              :rust
                                                                              :typescript
                                                                              :typescriptreact
                                                                              :javascript
                                                                              :python
                                                                              :go
                                                                              :c
                                                                              :cpp
                                                                              :ruby
                                                                              :swift
                                                                              :csharp
                                                                              :toml
                                                                              :lua
                                                                              :gitcommit
                                                                              :java
                                                                              :html]
                                                                  :settings {:harper-ls {:userDictPath "~/.config/nvim/dict.txt"}}}))
                                   :rust_analyzer (fn []
                                                    (local {: rust_analyzer}
                                                           (require :lspconfig))
                                                    (rust_analyzer.setup {:cargo {:features [:ssr]}
                                                                          :procMacro {:ignored {:leptos_macro [:server]}}}))
                                   :lua_ls (fn []
                                             (local {: lua_ls}
                                                    (require :lspconfig))
                                             (lua_ls.setup {:Lua {:diagnostics {:globals [:vim]}
                                                                  :workspace {:checkThirdParty false}
                                                                  :telemetry {:enable false}}}))}})
