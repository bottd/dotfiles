;; Awesome WM configuration in Fennel
;; Main entry point

(local gears (require :gears))
(local awful (require :awful))
(local wibox (require :wibox))
(local beautiful (require :beautiful))
(local naughty (require :naughty))
(local menubar (require :menubar))

;; Load sub-modules
(local keybinds (require :keybinds))
(local rules (require :rules))
(local widgets (require :widgets))
(local theme (require :theme))

;; Error handling
(when awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :title "Startup Error"
                   :text awesome.startup_errors}))

(do
  (var in-error false)
  (awesome.connect_signal "debug::error"
                          (fn [err]
                            (when (not in-error)
                              (set in-error true)
                              (naughty.notify {:preset naughty.config.presets.critical
                                               :title :Error
                                               :text (tostring err)})
                              (set in-error false)))))

;; Initialize theme
(theme.init)

;; Default applications
(set _G.terminal :ghostty)
(set _G.editor (or (os.getenv :EDITOR) :nvim))
(set _G.editor_cmd (.. _G.terminal " -e " _G.editor))
(set _G.modkey :Mod4)

;; Layouts
(set awful.layout.layouts [awful.layout.suit.tile
                           awful.layout.suit.tile.left
                           awful.layout.suit.tile.bottom
                           awful.layout.suit.fair
                           awful.layout.suit.floating
                           awful.layout.suit.max])

;; Menubar configuration
(set menubar.utils.terminal _G.terminal)

;; Create a launcher widget and main menu
(local awesome-menu [[:restart awesome.restart] [:quit awesome.quit]])

(local main-menu
       (awful.menu {:items [[:awesome awesome-menu beautiful.awesome_icon]
                            [:terminal _G.terminal]]}))

(local launcher (awful.widget.launcher {:image beautiful.awesome_icon
                                        :menu main-menu}))

;; Wibar setup
(widgets.setup-wibar launcher)

;; Set keys and buttons
(keybinds.setup)

;; Rules
(rules.setup)

;; Signals
(client.connect_signal :manage
                       (fn [c]
                         (when (and awesome.startup
                                    (not c.size_hints.user_position)
                                    (not c.size_hints.program_position))
                           (awful.placement.no_offscreen c))))

(client.connect_signal "mouse::enter"
                       (fn [c]
                         (c:emit_signal "request::activate" :mouse_enter
                                        {:raise false})))

(client.connect_signal :focus
                       (fn [c] (set c.border_color beautiful.border_focus)))

(client.connect_signal :unfocus
                       (fn [c] (set c.border_color beautiful.border_normal)))

;; Autostart
(awful.spawn.with_shell "picom &")
(awful.spawn.with_shell "nm-applet &")
(awful.spawn.with_shell "pasystray &")
