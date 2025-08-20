(set vim.o.timeout true)
(set vim.o.timeoutlen 300)
(local wk (require :which-key))
(wk.add [{1 :<C-w><space> 2 (fn [] (wk.show {:keys :<C-w :loop true}))}
         {1 :<leader>w
          :group :windows
          :proxy :<c-w>
          :expand (fn [] (. :expand.win (require :which-key.extras)))}])
