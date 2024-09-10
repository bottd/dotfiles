(local icons (require :icons))
(local {: get-system-palette : on-theme-change} (require :colors))
(local popup-toggle "sketchybar --set $NAME popup.drawingtoggle")

(local base-palette (get-system-palette))
(local apple-logo (sbar.add :item
                            {:padding_right 15
                             :click_script popup-toggle
                             :icon {:string icons.apple
                                    :font {:size 16.0}
                                    :color base-palette.blue}
                             :label {:drawing false}
                             :popup {:height 35}}))

(local apple-prefs (sbar.add :item
                             {:position (.. :popup. apple-logo.name)
                              :icon {:string icons.preferences
                                     :color base-palette.blue}
                              :label :Preferences}))

(apple-prefs:subscribe :mouse.clicked
                       (fn []
                         (sbar.exec "open -a 'System Preferences'")
                         (apple-logo:set {:popup {:drawing false}})))

(on-theme-change (fn [palette]
                   (apple-logo:set {:icon {:color palette.red}})))

