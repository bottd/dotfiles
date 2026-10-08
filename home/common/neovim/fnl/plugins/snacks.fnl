(local snacks (require :snacks))
(local wk (require :which-key))

(snacks.setup {:bigfile {:enabled true}
               :gitbrowse {:enabled true}
               :lazygit {:enabled true}
               :zen {:enabled true}
               :win {:enabled true}
               :picker {:layout {:preset :ivy_split}}
               :styles {:zen {:backdrop {:transparent false}}}
               :image (or vim.g.dotfiles_snacks_image {:enabled false})
               :dashboard {:enabled true
                           :sections [{:section :terminal
                                       :cmd "fortune -s | cowsay -f stegosaurus"
                                       :hl :header
                                       :height 24
                                       :width 68}
                                      {:icon " "
                                       :title :Projects
                                       :section :projects
                                       :indent 2
                                       :padding 1}
                                      {:icon " "
                                       :title "Recent Files"
                                       :section :recent_files
                                       :indent 2
                                       :padding 1}]}})

(wk.add [{1 :<leader>gg 2 #(Snacks.lazygit) :desc :Lazygit}
         {1 :<leader>gw
          2 #(Snacks.gitbrowse)
          :desc "Open in browser"
          :icon " "}
         {1 :<leader>wz 2 #(Snacks.zen) :desc "Zen mode" :icon "󱅻 "}
         {1 :<leader>f :group :Find}
         {1 :<leader>ff 2 #(Snacks.picker.files) :desc :Files}
         {1 :<leader>fs 2 #(Snacks.picker.grep) :desc :String}
         {1 :<leader>fb 2 #(Snacks.picker.buffers) :desc :Buffer}
         {1 :<leader>fk 2 #(Snacks.picker.keymaps) :desc :Keymap}
         {1 :<leader>fh 2 #(Snacks.picker.help) :desc "Help Pages"}
         {1 :<leader>fm 2 #(Snacks.picker.man) :desc "Man Pages"}])
