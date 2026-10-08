(local blink (require :blink.cmp))

(blink.setup {:keymap {:preset :super-tab}
              :term {:enabled true}
              :signature {:enabled true}
              :appearance {:kind_icons {}}
              :fuzzy {:sorts [:exact :score :sort_text]}
              :sources {:default [:lsp :path :snippets :buffer :omni :cmdline]}
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
