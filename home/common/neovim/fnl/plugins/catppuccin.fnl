(local catppuccin (require :catppuccin))

(catppuccin.setup {:flavor :auto
                   :background {:light :latte :dark :mocha}
                   :custom_highlights (fn [colors]
                                        {:MiniIndentscopeSymbol {:fg colors.lavender}})
                   :integrations {:blink_cmp true
                                  :cmp false
                                  :which_key true
                                  :indent_blankline {:enabled true
                                                     :colored_indent_levels true}}})
