(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(let [flavor (os.getenv :CATPPUCCIN_FLAVOR)]
  (when (= flavor :latte)
    (set vim.o.background :light)))

(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})
(vim.keymap.set :v :<Leader>y "\"+y" {:desc "Yank to clipboard"})
