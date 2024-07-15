(set vim.o.timeout true)
(set vim.o.timeoutlen 300)
(let [which-key (require :which-key)] 
  (which-key.setup))
