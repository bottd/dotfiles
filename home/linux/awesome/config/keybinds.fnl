;; Keybindings for Awesome WM

(local gears (require :gears))
(local awful (require :awful))
(local hotkeys_popup (require :awful.hotkeys_popup))

(local M {})

(fn M.setup []
  (local modkey _G.modkey)
  ;; Global keys
  (local globalkeys
         (gears.table.join ;; Help
                           (awful.key [modkey] :s hotkeys_popup.show_help
                                      {:description "show help"
                                       :group :awesome})
                           ;; Tag navigation
                           (awful.key [modkey] :Left awful.tag.viewprev
                                      {:description "view previous"
                                       :group :tag})
                           (awful.key [modkey] :Right awful.tag.viewnext
                                      {:description "view next" :group :tag})
                           (awful.key [modkey] :Escape
                                      awful.tag.history.restore
                                      {:description "go back" :group :tag})
                           ;; Client focus
                           (awful.key [modkey] :j
                                      (fn [] (awful.client.focus.byidx 1))
                                      {:description "focus next"
                                       :group :client})
                           (awful.key [modkey] :k
                                      (fn [] (awful.client.focus.byidx -1))
                                      {:description "focus previous"
                                       :group :client})
                           ;; Layout manipulation
                           (awful.key [modkey :Shift] :j
                                      (fn [] (awful.client.swap.byidx 1))
                                      {:description "swap with next"
                                       :group :client})
                           (awful.key [modkey :Shift] :k
                                      (fn [] (awful.client.swap.byidx -1))
                                      {:description "swap with previous"
                                       :group :client})
                           (awful.key [modkey :Control] :j
                                      (fn [] (awful.screen.focus_relative 1))
                                      {:description "focus next screen"
                                       :group :screen})
                           (awful.key [modkey :Control] :k
                                      (fn [] (awful.screen.focus_relative -1))
                                      {:description "focus previous screen"
                                       :group :screen})
                           ;; Standard programs
                           (awful.key [modkey] :Return
                                      (fn [] (awful.spawn _G.terminal))
                                      {:description "open terminal"
                                       :group :launcher})
                           (awful.key [modkey :Control] :r awesome.restart
                                      {:description "reload awesome"
                                       :group :awesome})
                           (awful.key [modkey :Shift] :q awesome.quit
                                      {:description "quit awesome"
                                       :group :awesome})
                           ;; Layout
                           (awful.key [modkey] :l
                                      (fn [] (awful.tag.incmwfact 0.05))
                                      {:description "increase master width"
                                       :group :layout})
                           (awful.key [modkey] :h
                                      (fn [] (awful.tag.incmwfact -0.05))
                                      {:description "decrease master width"
                                       :group :layout})
                           (awful.key [modkey :Shift] :h
                                      (fn [] (awful.tag.incnmaster 1 nil true))
                                      {:description "increase masters"
                                       :group :layout})
                           (awful.key [modkey :Shift] :l
                                      (fn [] (awful.tag.incnmaster -1 nil true))
                                      {:description "decrease masters"
                                       :group :layout})
                           (awful.key [modkey] :space
                                      (fn [] (awful.layout.inc 1))
                                      {:description "next layout"
                                       :group :layout})
                           (awful.key [modkey :Shift] :space
                                      (fn [] (awful.layout.inc -1))
                                      {:description "previous layout"
                                       :group :layout})
                           ;; Rofi
                           (awful.key [modkey] :p
                                      (fn [] (awful.spawn "rofi -show drun"))
                                      {:description "rofi launcher"
                                       :group :launcher})
                           (awful.key [modkey] :w
                                      (fn [] (awful.spawn "rofi -show window"))
                                      {:description "rofi window switcher"
                                       :group :launcher})
                           ;; Screenshot
                           (awful.key [] :Print
                                      (fn []
                                        (awful.spawn.with_shell "maim -s | xclip -selection clipboard -t image/png"))
                                      {:description "screenshot selection"
                                       :group :misc})
                           ;; Brightness (for pocket)
                           (awful.key [] :XF86MonBrightnessUp
                                      (fn []
                                        (awful.spawn "brightnessctl set +5%"))
                                      {:description "brightness up"
                                       :group :misc})
                           (awful.key [] :XF86MonBrightnessDown
                                      (fn []
                                        (awful.spawn "brightnessctl set 5%-"))
                                      {:description "brightness down"
                                       :group :misc})
                           ;; Volume
                           (awful.key [] :XF86AudioRaiseVolume
                                      (fn []
                                        (awful.spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
                                      {:description "volume up" :group :misc})
                           (awful.key [] :XF86AudioLowerVolume
                                      (fn []
                                        (awful.spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
                                      {:description "volume down" :group :misc})
                           (awful.key [] :XF86AudioMute
                                      (fn []
                                        (awful.spawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
                                      {:description "toggle mute" :group :misc})))
  ;; Tag keybindings (1-9)
  (for [i 1 9]
    (set globalkeys
         (gears.table.join globalkeys
                           (awful.key [modkey] (.. "#" (+ i 9))
                                      (fn []
                                        (local screen (awful.screen.focused))
                                        (local tag (. screen.tags i))
                                        (when tag (tag:view_only)))
                                      {:description (.. "view tag #" i)
                                       :group :tag})
                           (awful.key [modkey :Control] (.. "#" (+ i 9))
                                      (fn []
                                        (local screen (awful.screen.focused))
                                        (local tag (. screen.tags i))
                                        (when tag (awful.tag.viewtoggle tag)))
                                      {:description (.. "toggle tag #" i)
                                       :group :tag})
                           (awful.key [modkey :Shift] (.. "#" (+ i 9))
                                      (fn []
                                        (when client.focus
                                          (local tag
                                                 (. client.focus.screen.tags i))
                                          (when tag
                                            (client.focus:move_to_tag tag))))
                                      {:description (.. "move to tag #" i)
                                       :group :tag})
                           (awful.key [modkey :Control :Shift] (.. "#" (+ i 9))
                                      (fn []
                                        (when client.focus
                                          (local tag
                                                 (. client.focus.screen.tags i))
                                          (when tag
                                            (client.focus:toggle_tag tag))))
                                      {:description (.. "toggle focused on tag #"
                                                        i)
                                       :group :tag}))))
  (root.keys globalkeys)
  ;; Client keys
  (local clientkeys
         (gears.table.join (awful.key [modkey] :f
                                      (fn [c]
                                        (set c.fullscreen (not c.fullscreen))
                                        (c:raise))
                                      {:description "toggle fullscreen"
                                       :group :client})
                           (awful.key [modkey :Shift] :c (fn [c] (c:kill))
                                      {:description :close :group :client})
                           (awful.key [modkey :Control] :space
                                      awful.client.floating.toggle
                                      {:description "toggle floating"
                                       :group :client})
                           (awful.key [modkey :Control] :Return
                                      (fn [c] (c:swap (awful.client.getmaster)))
                                      {:description "move to master"
                                       :group :client})
                           (awful.key [modkey] :o (fn [c] (c:move_to_screen))
                                      {:description "move to screen"
                                       :group :client})
                           (awful.key [modkey] :t
                                      (fn [c] (set c.ontop (not c.ontop)))
                                      {:description "toggle on top"
                                       :group :client})
                           (awful.key [modkey] :n
                                      (fn [c] (set c.minimized true))
                                      {:description :minimize :group :client})
                           (awful.key [modkey] :m
                                      (fn [c]
                                        (set c.maximized (not c.maximized))
                                        (c:raise))
                                      {:description "toggle maximize"
                                       :group :client})))
  ;; Client buttons
  (local clientbuttons
         (gears.table.join (awful.button [] 1
                                         (fn [c]
                                           (c:emit_signal "request::activate"
                                                          :mouse_click
                                                          {:raise true})))
                           (awful.button [modkey] 1
                                         (fn [c]
                                           (c:emit_signal "request::activate"
                                                          :mouse_click
                                                          {:raise true})
                                           (awful.mouse.client.move c)))
                           (awful.button [modkey] 3
                                         (fn [c]
                                           (c:emit_signal "request::activate"
                                                          :mouse_click
                                                          {:raise true})
                                           (awful.mouse.client.resize c)))))
  ;; Export for rules
  (set _G.clientkeys clientkeys)
  (set _G.clientbuttons clientbuttons))

M
