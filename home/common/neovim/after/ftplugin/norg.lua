vim.opt_local.spell = true
vim.opt_local.conceallevel = 3
vim.opt_local.number = false
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- buffer-local: this file actually runs now, and a global <Cr> map would
-- follow you out of the norg buffer.
vim.keymap.set("n", "<Cr>", "<Plug>(neorg.esupports.hop.hop-link)", { buffer = true })
