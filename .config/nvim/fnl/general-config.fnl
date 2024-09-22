(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

;; Copy to clipboard
(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})

;; Escape terminal mode
(vim.keymap.set :t :<Esc> "<C-\\\\><C-n>")

