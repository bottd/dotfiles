{
  1 "folke/flash.nvim"
  :event "VeryLazy"
  :opts {}
  :keys [
    { 
      1 "s"
      :mode ["n" "x" "o" ] 
      2 (fn [] 
        (let [flash (require :flash)] 
          (flash.jump)
       ))
      :desc "Flash" 
    }
    { 
      1 "S"
      :mode ["n" "o" "x" ]
      2 (fn [] 
         (let [flash (require :flash)] 
          (flash.treesitter)
      ))
      :desc "Flash Treesitter" 
    }
    { 
      1 "r"
      :mode "o"
      2 (fn [] 
         (let [flash (require :flash)] 
          (flash.remote)
      ))
      :desc "Remote Flash" 
    }
    { 
      1 "R"
      :mode ["o" "x"]
      2 (fn [] 
         (let [flash (require :flash)] 
          (flash.treesitter_search)
      ))
      :desc "Treesitter Search" 
    }
    { 
      1 "<c-s>"
      :mode ["c"]
      2 (fn [] 
         (let [flash (require :flash)] 
          (flash.toggle)
      ))
      :desc "Toggle Flash Search" 
    }
  ]
}
