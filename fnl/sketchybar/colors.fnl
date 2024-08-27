(local palette-dark (require :catppuccin.mocha))
(local palette-light (require :catppuccin.latte))

(fn rgb-to-argb [rgb]
  (local (r g b) (table.unpack rgb))
  ;; Default alpha to full (255) opacity
  (string.format "0x%02x%02x%02x%02x" 255 r g b))

(each [key dark-color (pairs palette-dark)]
  (when (not= key :name)
    (local light-color (. palette-light key))
    (tset palette-dark key (rgb-to-argb dark-color.rgb))
    (tset palette-light key (rgb-to-argb light-color.rgb))))

(fn get-palette [scheme]
  (if (= scheme :Dark)
      palette-dark
      palette-light))

(fn get-system-palette []
  (local handle (io.popen "defaults read -g AppleInterfaceStyle"))
  (local system-colors (handle:read))
  (handle:close)
  (get-palette system-colors))

(local event (sbar.add :event :theme-change
                       :AppleInterfaceThemeChangedNotification))

(local theme-watcher (sbar.add :item {:drawing false}))

(fn on-theme-change [handler]
  (theme-watcher:subscribe :theme-change (fn [] (handler (get-system-palette)))))

{: get-system-palette : on-theme-change}

