{
  1 :nvim-telescope/telescope.nvim
  :dependencies [
    :debugloop/telescope-undo.nvim
    {
      1 :nvim-telescope/telescope-fzf-native.nvim
      :build "arch -arm64 make"
    }
  ]
  :config (fn []
    (let [telescope (require :telescope)]
      (telescope.setup {
        :pickers {
          :find_files {
            :layout_strategy "vertical"
          }
          :live_grep {
            :layout_strategy "vertical"
          }
        }
        :extensions {
          :fzf {
            :fuzzy true
            :override_generic_sorter true
            :override_file_sorter true
            :case_mode "smart_case"
          }
          :undo {
            :use_delta true
          }
        }
      })
      (telescope.load_extension :fzf)
      (telescope.load_extension :undo)
    )
  )
  :keys [
   {
     :mode "n" 
     1 "<leader>fb"
     2 ":Telescope buffers<Cr>"
     :desc "Find Buffer"
   }
   {
     :mode "n" 
     1 "<leader>ff"
     2 ":Telescope find_files<Cr>"
     :desc "Find Files"
   }
   {
     :mode "n" 
     1 "<leader>fs"
     2 ":Telescope live_grep<Cr>"
     :desc "Find String"
   }
   {
     :mode "n" 
     1 "<leader>fk"
     2 ":Telescope keymaps<Cr>"
     :desc "Find Keymap"
   }
   {
     :mode "n" 
     1 "<leader>fh"
     2 ":Telescope help_tags<Cr>"
     :desc "Find Help"
   }
   {
     :mode "n" 
     1 "<leader>fu"
     2 ":Telescope undo<Cr>"
     :desc "Undo Tree"
   }
  ]
}
