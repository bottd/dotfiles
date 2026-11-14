;; Stopgap for what rocks-config.nvim and rocks-treesitter.nvim did, until
;; lux-config.nvim / lux-treesitter.nvim are published. Mirrors the commented
;; sections at the bottom of lux.toml; delete each part as its port lands.

;; [config.options]
(each [k v (pairs {:cursorline true
                   :expandtab true
                   :foldlevelstart 99
                   :guifont "MonoLisa Nerd Font"
                   :number true
                   :shiftwidth 2
                   :smartindent true
                   :tabstop 2
                   :timeout true
                   :timeoutlen 300
                   :equalalways false
                   :winborder :rounded
                   :winwidth 10
                   :winminwidth 10})]
  (tset vim.o k v))

;; [config] auto_setup: plugins with no fnl/plugins/ module but a setup().
(each [_ mod (ipairs [:lazydev :blink.indent :nvim-web-devicons])]
  (let [(ok m) (pcall require mod)]
    (when (and ok (= (type m) :table) m.setup)
      (m.setup {}))))

;; plugins/<name> modules. One failure shouldn't take down the rest.
(each [_ path (ipairs (vim.api.nvim_get_runtime_file :fnl/plugins/*.fnl true))]
  (let [name (vim.fn.fnamemodify path ":t:r")
        (ok err) (pcall require (.. :plugins. name))]
    (when (not ok)
      (vim.notify (.. :plugins/ name ": " (tostring err)) vim.log.levels.ERROR))))

;; [treesitter] auto_highlight = "all" and parser_map
(vim.treesitter.language.register :fennel :lisp)
(vim.treesitter.language.register :janet_simple :janet)
(vim.api.nvim_create_autocmd :FileType
                             {:group (vim.api.nvim_create_augroup :lux-treesitter-stopgap
                                                                  {})
                              :callback #(pcall vim.treesitter.start $1.buf)})
