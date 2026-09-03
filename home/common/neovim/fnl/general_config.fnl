(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})
(vim.keymap.set :v :<Leader>y "\"+y" {:desc "Yank to clipboard"})

(tset vim.g "conjure#filetypes" [:janet])

(tset vim.g "conjure#filetype#janet" :conjure.client.janet.stdio)
