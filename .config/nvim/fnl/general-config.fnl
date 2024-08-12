(set vim.o.guifont "MonoLisa Nerd Font")
(set vim.g.mapleader " ")

;; Copy to clipboard
(vim.keymap.set :n :<Leader>y "\"+y" {:desc "Yank to clipboard"})

;; Escape terminal mode
(vim.keymap.set :t :<Esc> "<C-\\\\><C-n>")

;; windows.nvim settings
(set vim.o.winwidth 10)
(set vim.o.winminwidth 10)
(set vim.o.equalalways false)

