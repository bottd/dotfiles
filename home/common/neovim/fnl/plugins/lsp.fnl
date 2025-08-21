(local blink (require :blink.cmp))
(local lspconfig (require :lspconfig))
(local wk (require :which-key))
(local lsp-lines (require :lsp_lines))

(lsp-lines.setup)

(wk.add [{1 :<leader>m :desc :Meta}
         {1 :<leader>ml 2 lsp-lines.toggle :desc "Toggle Lsp Info"}])

(vim.keymap.set :n :gl vim.diagnostic.open_float)
(vim.keymap.set :n "[d" #(vim.diagnostic.jump {:count -1 :float true}))
(vim.keymap.set :n "]d" #(vim.diagnostic.jump {:count 1 :float true}))

(vim.api.nvim_create_autocmd :LspAttach
                             {:desc "LSP Actions"
                              :callback (fn [event]
                                          (let [opts {:buffer event.buf}]
                                            (vim.keymap.set :n :K
                                                            vim.lsp.buf.hover
                                                            opts)
                                            (vim.keymap.set :n :gd
                                                            vim.lsp.buf.definition
                                                            opts)
                                            (vim.keymap.set :n :gD
                                                            vim.lsp.buf.declaration
                                                            opts)
                                            (vim.keymap.set :n :gi
                                                            vim.lsp.buf.implementation
                                                            opts)
                                            (vim.keymap.set :n :go
                                                            vim.lsp.buf.type_definition
                                                            opts)
                                            (vim.keymap.set :n :gr
                                                            vim.lsp.buf.references
                                                            opts)
                                            (vim.keymap.set :n :gs
                                                            vim.lsp.buf.signature_help
                                                            opts)
                                            (vim.keymap.set :n :<F2>
                                                            vim.lsp.buf.rename
                                                            opts)
                                            (vim.keymap.set :n :<F4>
                                                            vim.lsp.buf.code_action
                                                            opts)))})

(local servers
       {:cssls {}
        :eslint {}
        :graphql {}
        :html {}
        :svelte {}
        :tailwindcss {}
        :ts_ls {}
        :rust_analyzer {}
        :harper_ls {:filetypes [:markdown]
                    :settings {:harper-ls {:userDictPath "~/.config/nvim/dict.txt"}}}
        :lua_ls {:Lua {:diagnostics {:globals [:vim]}
                       :workspace {:checkThirdParty false}
                       :telemetry {:enable false}}}
        :clojure_lsp {:filetypes [:clojure :edn :clojurescript :clojurec]
                      :settings {:clojure_lsp {:lint {:level :on}}}}})

(each [server config (pairs servers)]
  (set config.capabilities (blink.get_lsp_capabilities config.capabilities))
  ((. lspconfig server :setup) config))

(vim.diagnostic.config {:virtual_text false :virtual_lines true})
