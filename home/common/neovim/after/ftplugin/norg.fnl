(set vim.opt.spell true)
(set vim.opt.conceallevel 3)
(vim.api.nvim_command "set nonumber")
(vim.api.nvim_command "set linebreak")
(vim.api.nvim_command "set breakindent")

(vim.keymap.set :n :<Cr> "<Plug>(neorg.esupports.hop.hop-link)")
