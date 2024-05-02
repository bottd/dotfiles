;; Vim settings
(vim.api.nvim_command "set number")
(vim.api.nvim_command "set cursorline")
(vim.api.nvim_command "set smartindent")
(set vim.opt.expandtab  true)
(set vim.opt.tabstop  2)
(set vim.opt.shiftwidth  2)
(set vim.opt.foldlevelstart  99)
(set vim.opt.spell true)
(set vim.opt.spelllang [:en_us])
(set vim.o.guifont "MonoLisa Nerd Font")
(set vim.g.mapleader " ")
(set vim.g.maplocalleader " ")

;; Copy to clipboard
(vim.keymap.set :n :<Leader>y "\"+y" { :desc "Yank to clipboard" })

;; Escape terminal mode
(vim.keymap.set :t :<Esc> :<C-\\><C-n>)


