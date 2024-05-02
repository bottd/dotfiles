{
  1 :nvim-pack/nvim-spectre
  :keys [
    { 
      :mode "n" 
      1 "<leader>S<Cr>"
      2 (fn [] ((. (require :spectre) :toggle)))
      :desc "Toggle Spectre"
    }
    { 
      :mode "n" 
      1 "<leader>sw<Cr>"
      2 (fn [] ((. (require :spectre) :open_visual) { :select_word true }))
      :desc "Search current word"
    }
    { 
      :mode "v" 
      1 "<leader>sw<Cr>"
      2 (fn [] ((. (require :spectre) :open_visual)))
      :desc "Search current word"
    }
    { 
      :mode "n" 
      1 "<leader>sp<Cr>"
      2 (fn [] ((. (require :spectre) :open_file_search) {:select_word true }))
      :desc "Search on current file"
    }
  ]
}
