;; Window rules for Awesome WM

(local awful (require :awful))
(local beautiful (require :beautiful))

(local M {})

(fn M.setup []
  (set awful.rules.rules
       [;; All clients
        {:rule {}
         :properties {:border_width beautiful.border_width
                      :border_color beautiful.border_normal
                      :focus awful.client.focus.filter
                      :raise true
                      :keys _G.clientkeys
                      :buttons _G.clientbuttons
                      :screen awful.screen.preferred
                      :placement (+ awful.placement.no_overlap
                                    awful.placement.no_offscreen)}}
        ;; Floating clients
        {:rule_any {:instance [:pinentry]
                    :class [:Arandr
                            :Gpick
                            :Kruler
                            :MessageWin
                            :Sxiv
                            "Tor Browser"
                            :Wpa_gui
                            :veromix
                            :xtightvncviewer
                            :pavucontrol
                            :nm-connection-editor]
                    :name ["Event Tester"]
                    :role [:AlarmWindow :ConfigManager :pop-up]}
         :properties {:floating true}}
        ;; Add titlebars to dialogs
        {:rule_any {:type [:dialog]} :properties {:titlebars_enabled true}}]))

M
