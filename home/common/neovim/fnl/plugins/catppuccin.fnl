(local {: setup} (require :catppuccin))
(setup {:background {:light :latte :dark :mocha}
        :flavor :auto
        :custom_highlights (fn [colors]
                             {:MiniIndentscopeSymbol {:fg colors.lavender}})
        :integrations {:blink_cmp true
                       :cmp false
                       :indent_blankline {:enabled true
                                          :colored_indent_levels true}
                       :which_key true}})
