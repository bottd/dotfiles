(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

;; nvim only sources ftdetect/*.{vim,lua}, never *.fnl, so these live here.
(vim.filetype.add {:extension {:mg :mog :bb :clojure}})

(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})
(vim.keymap.set :v :<Leader>y "\"+y" {:desc "Yank to clipboard"})
