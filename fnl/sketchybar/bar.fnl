(local {: get-system-palette : on-theme-change} (require :colors))

(local base-palette (get-system-palette))
;; Equivalent to the --bar domain
(local bar (sbar.bar {:height 40
                      :color base-palette.crust
                      ;; border_color colors.red
                      :shadow true
                      :sticky true
                      :padding_right 10
                      :padding_left 10
                      :blur_radius 20
                      :topmost :window}))

