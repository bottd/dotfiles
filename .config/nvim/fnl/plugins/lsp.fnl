(local mason (require :mason))
(local mason_lspconfig (require :mason-lspconfig))

; note: diagnostics are not exclusive to lsp servers
; so these can be global keybindings
(vim.keymap.set :n :gl (fn [] (vim.diagnostic.open_float)))
(vim.keymap.set :n "[d" (fn [] (vim.diagnostic.goto_prev)))
(vim.keymap.set :n "]d" (fn [] (vim.diagnostic.goto_next)))

(vim.api.nvim_create_autocmd :LspAttach
                             {:desc "LSP Actions"
                              :callback (fn [event]
                                          (local opts {:buffer event.buf}) ; these will be buffer-local keybindings
                                          ; because they only work if you have an active language server
                                          (vim.keymap.set :n :K
                                                          (fn []
                                                            (vim.lsp.buf.hover))
                                                          opts)
                                          (vim.keymap.set :n :gd
                                                          (fn []
                                                            (vim.lsp.buf.definition))
                                                          opts)
                                          (vim.keymap.set :n :gD
                                                          (fn []
                                                            (vim.lsp.buf.declaration))
                                                          opts)
                                          (vim.keymap.set :n :gi
                                                          (fn []
                                                            (vim.lsp.buf.implementation))
                                                          opts)
                                          (vim.keymap.set :n :go
                                                          (fn []
                                                            (vim.lsp.buf.type_definition))
                                                          opts)
                                          (vim.keymap.set :n :gr
                                                          (fn []
                                                            (vim.lsp.buf.references))
                                                          opts)
                                          (vim.keymap.set :n :gs
                                                          (fn []
                                                            (vim.lsp.buf.signature_help))
                                                          opts)
                                          (vim.keymap.set :n :<F2>
                                                          (fn []
                                                            (vim.lsp.buf.rename))
                                                          opts)
                                          (vim.keymap.set :n :<F4>
                                                          (fn []
                                                            (vim.lsp.buf.code_action))
                                                          opts))})

(mason.setup {})

(mason_lspconfig.setup {:ensure_installed [:cssls
                                           :eslint
                                           :graphql
                                           :html
                                           :jsonnet_ls
                                           :rust_analyzer
                                           :sqlls
                                           :lua_ls
                                           :svelte
                                           :tailwindcss
                                           :ts_ls
                                           ;:fennel_ls
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
                                                                              :markdown]
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
