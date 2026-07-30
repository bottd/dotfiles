(set vim.opt_local.spell true)
(set vim.opt_local.conceallevel 3)
(set vim.opt_local.number false)
(set vim.opt_local.linebreak true)
(set vim.opt_local.breakindent true)

;; buffer-local: this file actually runs now, and a global <Cr> map would
;; follow you out of the norg buffer.
(vim.keymap.set :n :<Cr> "<Plug>(neorg.esupports.hop.hop-link)" {:buffer true})
