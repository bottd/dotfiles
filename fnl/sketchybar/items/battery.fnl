(local icons (require :icons))

(local battery (sbar.add :item
                         {:position :right
                          :icon {:font {:style :Regular :size 19.0}}
                          :label {:drawing false}
                          :update_freq 120}))

(fn battery_update []
  (sbar.exec "pmset -g batt"
             (fn [batt-info]
               (var icon "!")
               (when (string.find batt_info "AC Power")
                 (set icon icons.battery.charging))
               (var (found _ charge) (batt_info:find "(%d+)%%"))
               (when found (set charge (tonumber charge)))
               (set icon (match [found charge]
                           (where [true charge] (> charge 80)) icons.battery._100
                           (where [true charge] (> charge 60)) icons.battery._75
                           (where [true charge] (> charge 40)) icons.battery._40
                           (where [true charge] (> charge 20)) icons.battery._20
                           _ icons.battery._0))
               (battery:set {: icon}))))

(battery:subscribe [:routine :power_source_change :system_woke] battery_update)

