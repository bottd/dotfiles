(match vim.g.stylix_theme
  :tokyonight (let [tokyonight (require :tokyonight)]
                (tokyonight.setup {:style (if (= vim.g.stylix_appearance :light)
                                              :day
                                              :storm)
                                   :on_highlights (fn [hl colors]
                                                    (tset hl
                                                          :MiniIndentscopeSymbol
                                                          {:fg colors.purple}))
                                   :plugins {:indent_blankline true}})
                (vim.cmd.colorscheme :tokyonight))
  :solarized-light (let [solarized (require :solarized)]
                     (solarized.setup {})
                     (vim.cmd.colorscheme :solarized)))
