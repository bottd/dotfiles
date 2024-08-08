(let [telescope (require :telescope)]
  (telescope.setup {:pickers {:find_files {:layout_strategy :vertical}
                              :live_grep {:layout_strategy :vertical}}
                    :extensions {:fzf {:fuzzy true
                                       :override_generic_sorter true
                                       :override_file_sorter true
                                       :case_mode :smart_case}
                                 :undo {:use_delta true}}})
  (telescope.load_extension :fzf)
  (telescope.load_extension :undo))

(vim.keymap.set :n :<leader>fb ":Telescope buffers<Cr>" {:desc "Find Buffer"})

(vim.keymap.set :n :<leader>ff ":Telescope find_files<Cr>" {:desc "Find Files"})

(vim.keymap.set :n :<leader>fs ":Telescope live_grep<Cr>" {:desc "Find String"})

(vim.keymap.set :n :<leader>fk ":Telescope keymaps<Cr>" {:desc "Find Keymap"})

(vim.keymap.set :n :<leader>fh ":Telescope help_tags<Cr>" {:desc "Find Help"})

(vim.keymap.set :n :<leader>fu ":Telescope undo<Cr>" {:desc "Undo Tree"})

(let [which-key (require :which-key)]
  (which-key.add [{1 :<leader>f :desc :Find}]))

