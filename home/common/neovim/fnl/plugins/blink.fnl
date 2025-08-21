(local cmp-npm (require :cmp-npm))
(local blink (require :blink.cmp))

(cmp-npm.setup)

(blink.setup {:keymap [:preset :super-tab]
              :snippets [:preset :luasnip]
              :term {:enabled true}
              :signature {:enabled true}
              :appearance {:kind_icons {}}
              :fuzzy {:sorts [:exact :score :sort_text]}
              :sources {:default [:lsp
                                  :path
                                  :snippets
                                  :buffer
                                  :omni
                                  :cmdline
                                  :npm]
                        :providers {:npm {:name :npm
                                          :module :blink.compat.source}}}
              :completion {:keyword {:range :prefix}
                           :documentation {:auto_show true}
                           :ghost_text {:enabled true}
                           :list {:selection {:preselect true
                                              :auto_insert true}}
                           :menu {:draw {:treesitter [:lsp]
                                         :columns [[:source_name]
                                                   [:kind_icon]
                                                   [:kind]
                                                   {1 :label
                                                    2 :label_description
                                                    :gap 1}]}}}})
