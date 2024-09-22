(set vim.g.mapleader " ")

;; Copy to clipboard
(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})

;; Escape terminal mode
(vim.keymap.set :t :<Esc> "<C-\\\\><C-n>")

