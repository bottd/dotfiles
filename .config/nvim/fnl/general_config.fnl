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

;; Copy to clipboard
(vim.keymap.set :n :<Leader>y "\"+y" { :desc "Yank to clipboard" })

;; Escape terminal mode
(vim.keymap.set :t :<Esc> :<C-\\><C-n>)
