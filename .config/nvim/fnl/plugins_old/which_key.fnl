{
  1 :folke/which-key.nvim
  :config (fn []
     (set vim.o.timeout true)
     (set vim.o.timeoutlen 300)
     (let [which-key (require :which-key)] 
       (which-key.setup)
       (which-key.register {
       :e "Evaluate [Conjure]"
       :w "Window"
       :f {
         :name "Find"
       }
       :l "Log [Conjure]"
       :n "Neorg"
     } { :prefix "<leader>"})
  ))
}
