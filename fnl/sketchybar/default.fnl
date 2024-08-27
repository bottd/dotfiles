(local settings (require :settings))
(local {: get-system-palette : on-theme-change} (require :colors))

;; Equivalent to the --default domain
(local base-palette (get-system-palette))
(sbar.default {:updates :when_shown
               :icon {:font {:family settings.font :style :Bold :size 14.0}
                      :color base-palette.text
                      :padding_left settings.paddings
                      :padding_right settings.paddings}
               :label {:font {:family settings.font
                              :style :Semibold
                              :size 13.0}
                       :color base-palette.text
                       :padding_left settings.paddings
                       :padding_right settings.paddings}
               :background {:height 26 :corner_radius 9 :border_width 2}
               :popup {:background {:border_width 2
                                    :corner_radius 9
                                    :border_color base-palette.overlay1
                                    :color base-palette.overlay0
                                    :shadow {:drawing true}}
                       :blur_radius 20}
               :padding_left 5
               :padding_right 5})

(on-theme-change (fn [palette]
                   (sbar.default {:label {:color palette.text}
                                  :icon {:color palette.text}
                                  :popup {:background {:border_color palette.overlay1
                                                       :color palette.overlay0}}})))

