(local {: setup} (require :catppuccin))
(setup {:background {:light :latte :dark :mocha}
        :flavor :auto
        :custom_highlights (fn [colors]
                             {:MiniIndentscopeSymbol {:fg colors.lavender}})})
