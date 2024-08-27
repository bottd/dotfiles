(local {: on-theme-change : get-system-palette} (require :colors))

(local base-palette (get-system-palette))

(local front_app (sbar.add :item
                           {:icon {:drawing false}
                            :label {:color base-palette.blue
                                    :font {:size 12.0}}}))

(front_app:subscribe :front_app_switched
                     (fn [env]
                       (local palette (get-system-palette))
                       (front_app:set {:label {:string env.INFO}})
                       ;; Hack to sync bar color, no idea why but this doesn't work
                       ;; in on-theme-change or in any :theme-change handler
                       (sbar.exec (.. "sketchybar --bar color=" palette.crust)
                                  (fn []))))

(on-theme-change (fn [palette]
                   (front_app:set {:label {:color palette.blue}})))

