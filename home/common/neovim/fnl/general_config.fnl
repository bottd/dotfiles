(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(when (= vim.g.stylix_appearance :light)
  (set vim.o.background :light))

(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})
(vim.keymap.set :v :<Leader>y "\"+y" {:desc "Yank to clipboard"})
