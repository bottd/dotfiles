(local blink (require :blink.cmp))
(local wk (require :which-key))
; virtual_lines is built in since nvim 0.11 (upstreamed lsp_lines.nvim)
(fn toggle-virtual-lines []
  (let [on (. (vim.diagnostic.config) :virtual_lines)]
    (vim.diagnostic.config {:virtual_lines (not on)})))

(wk.add [{1 :<leader>m :desc :Meta}
         {1 :<leader>ml 2 toggle-virtual-lines :desc "Toggle Lsp Info"}])

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

;; Set blink.cmp capabilities for all LSP servers
(vim.lsp.config "*" {:capabilities (blink.get_lsp_capabilities)})

;; Server configs in lsp dir
(local servers [:lua_ls :janet_lsp :nixd])

(vim.list_extend servers (or vim.g.dotfiles_extra_lsp_servers []))

(vim.lsp.enable servers)

(vim.diagnostic.config {:virtual_text false :virtual_lines false})
