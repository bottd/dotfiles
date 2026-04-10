(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(set vim.o.background vim.g.stylix_appearance)

(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})
(vim.keymap.set :v :<Leader>y "\"+y" {:desc "Yank to clipboard"})
