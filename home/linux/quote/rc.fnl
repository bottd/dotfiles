;;; quote awesome config (fennel, compiled to rc.lua by home-manager).
;;; minecraft b1.7.3 sits below as a click-through wallpaper.
;;;
;;; Bar + start menu come from xfce-winxp-tc (wintc-taskband), spawned at
;;; startup. We keep awesome responsible for titlebars, tags, demo mode, and
;;; MC framing — the taskband owns the bottom strip.

(local gears (require :gears))
(local awful (require :awful))
(require :awful.autofocus)
(local beautiful (require :beautiful))
(local naughty (require :naughty))
(local wibox (require :wibox))

;;; surface errors as notifications
(when awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :title "Awesome startup error"
                   :text awesome.startup_errors}))

(var in-error false)
(awesome.connect_signal "debug::error"
                        (fn [err]
                          (when (not in-error)
                            (set in-error true)
                            (naughty.notify {:preset naughty.config.presets.critical
                                             :title "Awesome runtime error"
                                             :text (tostring err)})
                            (set in-error false))))

;;; Theme
(beautiful.init (.. (gears.filesystem.get_themes_dir) :default/theme.lua))
(set beautiful.font "Tahoma 8")
(set beautiful.bg_normal "@bgNormal@")
(set beautiful.bg_focus "@bgFocus@")
(set beautiful.bg_urgent "@bgUrgent@")
(set beautiful.fg_normal "@fgNormal@")
(set beautiful.fg_focus "@fgFocus@")
(set beautiful.border_width 1)
(set beautiful.border_normal "@borderNormal@")
(set beautiful.border_focus "@borderFocus@")
(set beautiful.useless_gap 4)

(local terminal :ghostty)
(local modkey :Mod4)
(local altkey :Mod1)

;; floating first; tile variants stay reachable via Mod+e/s/w
(set awful.layout.layouts [awful.layout.suit.floating
                           awful.layout.suit.tile
                           awful.layout.suit.tile.bottom
                           awful.layout.suit.max])

(local bliss-path "@blissPath@")

(fn set-wallpaper [s]
  ;; ignore_aspect=false: scale-to-fill with crop, no distortion.
  (gears.wallpaper.maximized bliss-path s false))

(screen.connect_signal "property::geometry" set-wallpaper)

;;; --- XP Luna titlebars ---

(local xp-font-title "Tahoma Bold 9")
(local xp-text-white "#ffffff")

;; XP Luna palette (titlebar gradients)
(local xp-luna-shine "#5d92e7")
(local xp-luna-top "#3674d6")
(local xp-luna-mid "#245ecb")
(local xp-luna-bot "#1741a3")
(local xp-titlebar-inactive-top "#7c91b3")
(local xp-titlebar-inactive-bot "#475377")

(fn vgradient-h [stops h]
  (gears.color {:type :linear :from [0 0] :to [0 h] : stops}))

;; wintc ships hide/maximize/close PNGs (21x23, four variants each); the path
;; is filled in by replaceVars. See awesome.nix:xpButtonDir for rationale.
(local xp-button-dir "@xpButtonDir@")

(fn xp-button-icon [name variant]
  (.. xp-button-dir "/" name "-" variant :.png))

;; sized so the native 23-tall button PNGs fit with 1px of breathing room
(local xp-titlebar-height 24)
(local xp-titlebar-bg-focus
       (vgradient-h [[0 xp-luna-shine]
                     [0.04 xp-luna-top]
                     [0.5 xp-luna-mid]
                     [1 xp-luna-bot]] xp-titlebar-height))

(local xp-titlebar-bg-normal
       (vgradient-h [[0 xp-titlebar-inactive-top] [1 xp-titlebar-inactive-bot]]
                    xp-titlebar-height))

;; c.name is per-tab/world content; we want the app identity instead.
(fn xp-titlebar-title [c]
  (let [w (wibox.widget.textbox)
        update (fn [] (w:set_text (or c.class "")))]
    (update)
    (c:connect_signal "property::class" update)
    w))

(fn xp-titlebar-button [c {: name : on-click}]
  (let [active (xp-button-icon name :active)
        inactive (xp-button-icon name :inactive)
        prelight (xp-button-icon name :prelight)
        pressed (xp-button-icon name :pressed)
        idle (fn [] (if (= client.focus c) active inactive))
        img (wibox.widget {:widget wibox.widget.imagebox
                           :image (idle)
                           :forced_width 21
                           :forced_height 23})]
    (c:connect_signal :focus (fn [] (set img.image (idle))))
    (c:connect_signal :unfocus (fn [] (set img.image (idle))))
    (img:connect_signal "mouse::enter" (fn [] (set img.image prelight)))
    (img:connect_signal "mouse::leave" (fn [] (set img.image (idle))))
    (img:connect_signal "button::press" (fn [] (set img.image pressed)))
    ;; release-without-leave restores prelight (pointer still over button);
    ;; the mouse::leave handler will swap to idle if the user moves away.
    (img:connect_signal "button::release" (fn [] (set img.image prelight)))
    (img:buttons (gears.table.join (awful.button [] 1 on-click)))
    img))

(client.connect_signal "request::titlebars"
                       (fn [c]
                         (let [tb (awful.titlebar c
                                                  {:size xp-titlebar-height
                                                   :bg_focus xp-titlebar-bg-focus
                                                   :bg_normal xp-titlebar-bg-normal
                                                   :fg_focus xp-text-white
                                                   :fg_normal "#d9dde9"
                                                   :font xp-font-title})
                               icon-widget (awful.titlebar.widget.iconwidget c)
                               title-widget (xp-titlebar-title c)
                               drag-buttons (gears.table.join (awful.button []
                                                                            1
                                                                            (fn []
                                                                              (c:emit_signal "request::activate"
                                                                                             :titlebar
                                                                                             {:raise true})
                                                                              (awful.mouse.client.move c)))
                                                              (awful.button []
                                                                            3
                                                                            (fn []
                                                                              (c:emit_signal "request::activate"
                                                                                             :titlebar
                                                                                             {:raise true})
                                                                              (awful.mouse.client.resize c))))]
                           (set title-widget.align :left)
                           (set title-widget.font xp-font-title)
                           (tb:setup {:layout wibox.layout.align.horizontal
                                      1 {:layout wibox.layout.fixed.horizontal
                                         1 {:widget wibox.container.margin
                                            :left 4
                                            :right 6
                                            :top 3
                                            :bottom 3
                                            1 icon-widget}}
                                      2 (let [w (wibox.widget {:widget wibox.container.margin
                                                               :top 2
                                                               :bottom 2
                                                               1 title-widget})]
                                          (w:buttons drag-buttons)
                                          w)
                                      3 {:layout wibox.layout.fixed.horizontal
                                         :spacing 2
                                         1 (xp-titlebar-button c
                                                               {:name :hide
                                                                :on-click (fn []
                                                                            (set c.minimized
                                                                                 true))})
                                         2 (xp-titlebar-button c
                                                               {:name :maximize
                                                                :on-click (fn []
                                                                            (set c.maximized
                                                                                 (not c.maximized))
                                                                            (c:raise))})
                                         3 {:widget wibox.container.margin
                                            :right 4
                                            1 (xp-titlebar-button c
                                                                  {:name :close
                                                                   :on-click (fn []
                                                                               (c:kill))})}}}))))

;;; Per-screen setup: wallpaper + tags. The taskband owns the bottom strip.

(awful.screen.connect_for_each_screen (fn [s]
                                        (set-wallpaper s)
                                        (awful.tag [:1 :2 :3 :4] s
                                                   (. awful.layout.layouts 1))))

(local clientkeys
       (gears.table.join (awful.key [modkey] :q (fn [c] (c:kill)))
                         (awful.key [modkey] :f
                                    (fn [c]
                                      (set c.fullscreen (not c.fullscreen))
                                      (c:raise)))
                         (awful.key [modkey :Shift] :space
                                    awful.client.floating.toggle)))

(local clientbuttons
       (gears.table.join (awful.button [] 1
                                       (fn [c]
                                         (when c.focusable
                                           (c:emit_signal "request::activate"
                                                          :mouse_click
                                                          {:raise true}))))
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

;;; Alt+m / Alt+Shift+m switch between desk mode and demo mode:
;;; - desk mode (default): other screen-1 windows visible, MC frozen in the
;;;   back as a wallpaper-style cinematic (director's autoScreensaver on).
;;; - demo mode: MC focused with the pointer warped into it, MC unfrozen for
;;;   live play. Alt+m enters soft demo, leaving overlay windows in place.
;;;   Alt+Shift+m enters hard demo, also minimizing other screen-1 windows
;;;   out of the way. Either key leaves demo mode.
;;; The director flag is a filesystem touchpoint the mod watches; toggling it
;;; flips the freeze state. We mirror that flip with WM focus + minimize state
;;; so a single keypress drives both layers.
(local director-flag (.. (or (os.getenv :XDG_RUNTIME_DIR) :/tmp)
                         :/director/toggle-screensaver))

;; toggle-screensaver flips the freeze state, but its result depends on which
;; screen is currently open — it can't *guarantee* an outcome. attach/detach
;; need determinism, so they use directional flags: freeze-screensaver always
;; pauses into the cinematic; resume-screensaver always returns to live play
;; (and can never strand the game paused, whatever screen was showing).
(local director-freeze-flag
       (.. (or (os.getenv :XDG_RUNTIME_DIR) :/tmp)
           :/director/freeze-screensaver))

(local director-resume-flag
       (.. (or (os.getenv :XDG_RUNTIME_DIR) :/tmp)
           :/director/resume-screensaver))

(fn touch-director-flag []
  (awful.spawn [:touch director-flag]))

(fn touch-director-freeze []
  (awful.spawn [:touch director-freeze-flag]))

(fn touch-director-resume []
  (awful.spawn [:touch director-resume-flag]))

(fn find-mc-client []
  (var found nil)
  (each [_ c (ipairs (client.get)) &until found]
    (when (and c.class
               (or (= c.class :Minecraft)
                   (= c.class :org-prismlauncher-EntryPoint)))
      (set found c)))
  found)

(var demo-mode? false)
(var hidden-by-demo [])
(var pre-demo-focus nil)

(fn warp-pointer-to-client [c]
  (let [g (c:geometry)
        cx (math.floor (+ g.x (/ g.width 2)))
        cy (math.floor (+ g.y (/ g.height 2)))]
    (mouse.coords {:x cx :y cy})))

;; MC (GLFW) only re-grabs the pointer on a real mouse-button event, so after
;; warping into demo mode we synthesize a left click via XTest. Deferred to the
;; next main-loop tick so the focus + warp have been flushed to the X server
;; before the click lands.
(fn synthesize-left-click []
  (gears.timer.delayed_call (fn []
                              (root.fake_input :button_press 1)
                              (root.fake_input :button_release 1))))

(fn enter-demo-mode-soft [mc]
  (set hidden-by-demo [])
  (set pre-demo-focus client.focus)
  (set client.focus mc)
  (warp-pointer-to-client mc)
  (synthesize-left-click)
  (set demo-mode? true)
  (touch-director-flag))

(fn enter-demo-mode [mc]
  (set hidden-by-demo [])
  (set pre-demo-focus client.focus)
  (each [_ c (ipairs (client.get))]
    ;; Skip wintc-taskband so the bottom bar stays visible in demo mode.
    (when (and (= c.screen mc.screen) (not= c mc) (not c.minimized)
               (not= c.class :Wintc-taskband))
      (table.insert hidden-by-demo c)
      (set c.minimized true)))
  (set client.focus mc)
  (warp-pointer-to-client mc)
  (synthesize-left-click)
  (set demo-mode? true)
  (touch-director-flag))

(fn leave-demo-mode []
  (each [_ c (ipairs hidden-by-demo)]
    (when c.valid (set c.minimized false)))
  (set hidden-by-demo [])
  (when (and pre-demo-focus pre-demo-focus.valid (not pre-demo-focus.minimized))
    (set client.focus pre-demo-focus))
  (set pre-demo-focus nil)
  (set demo-mode? false)
  (touch-director-flag))

(fn director-toggle-soft []
  (if demo-mode?
      (leave-demo-mode)
      (let [mc (find-mc-client)]
        (if mc
            (enter-demo-mode-soft mc)
            ;; MC not running yet (early startup or crash) — fall back to
            ;; bare flag toggle so the keybind isn't dead.
            (touch-director-flag)))))

(fn director-toggle []
  (if demo-mode?
      (leave-demo-mode)
      (let [mc (find-mc-client)]
        (if mc
            (enter-demo-mode mc)
            (touch-director-flag)))))

;;; Alt+F: attach focus to the X11 window mirrored on the monitor block under
;;; the player's crosshair. Two-way IPC with quote-mc:
;;;   awesome → quote-mc: touch attach-request
;;;   quote-mc → awesome: write window title (or "" for no target) to
;;;                       attach-response, with a trailing newline so the file
;;;                       is always non-empty once written
;;; The mirrored windows (firefox, ghostty) run inside a nested Xephyr :2
;;; server — invisible to awesome's client.get, which only sees :0. And MC
;;; sits fullscreen *above* the (background) Xephyr window, so simply focusing
;;; Xephyr can't route the pointer there. Instead, on attach we:
;;;   1. save focus + pointer, focus the Xephyr window (MC's GLFW releases its
;;;      pointer grab on FocusOut), and touch the freeze flag;
;;;   2. DISPLAY=:2 xdotool focuses the specific window within :2 by the title
;;;      quote-mc reported;
;;;   3. synthesize Ctrl+Shift to fire Xephyr's own grab, confining real input
;;;      into :2 regardless of MC being on top.
;;; Xephyr's grab also holds the keyboard, so awesome's :0 Alt+F can't reach
;;; us while attached. An xbindkeys on :2 (started by the launcher) binds
;;; Alt+F to `touch detach-request`; awesome polls that flag while attached,
;;; and on seeing it drops Xephyr's grab (Ctrl+Shift), restores MC focus +
;;; pointer, unfreezes, and re-grabs MC's cursor — so Alt+F detaches too.
;;; Only fires while in demo mode — outside it, the crosshair has no meaning.
(local attach-request-flag
       (.. (or (os.getenv :XDG_RUNTIME_DIR) :/tmp) :/director/attach-request))

(local attach-response-flag
       (.. (or (os.getenv :XDG_RUNTIME_DIR) :/tmp) :/director/attach-response))

;; xbindkeys on :2 touches this when Alt+F is pressed inside Xephyr; rc.fnl
;; polls it to detach (awesome's :0 Alt+F can't reach us under Xephyr's grab).
(local detach-request-flag
       (.. (or (os.getenv :XDG_RUNTIME_DIR) :/tmp) :/director/detach-request))

(var attached? false)
(var attach-target nil)
(var attach-saved-pointer nil)
(var attach-saved-focus nil)
(var attach-target-was-hidden? false)
(var detach-poll-timer nil)

(fn trim [s]
  (let [s2 (string.gsub s "^%s+" "")
        s3 (string.gsub s2 "%s+$" "")]
    s3))

(fn file-exists? [path]
  (let [f (io.open path :r)]
    (if f (do
            (f:close) true) false)))

(fn regex-escape [s]
  ;; xdotool's `search --name` takes a POSIX extended regex; escape the
  ;; metacharacters so a window title matches itself literally.
  (pick-values 1 (string.gsub s "([%(%)%.%+%-%*%?%[%]%^%${}|\\])" "\\%1")))

(fn shell-quote [s]
  (.. "'" (pick-values 1 (string.gsub s "'" "'\\''")) "'"))

;; Xephyr doesn't reliably set WM_CLASS, so also match on its window name
;; ("Xephyr on :2.0 (ctrl+shift grabs ...)").
(fn xephyr-client? [c]
  (or (= c.class :Xephyr) (and c.name (string.find c.name :Xephyr 1 true) true)))

(fn find-xephyr-client []
  (var found nil)
  (each [_ c (ipairs (client.get)) &until found]
    (when (xephyr-client? c)
      (set found c)))
  found)

;; After MC loses focus its GLFW pointer grab is released; once that's flushed
;; we synthesize Ctrl+Shift to the (now focused) Xephyr window, firing its
;; built-in grab so real input is confined into the :2 server. The delay lets
;; MC's FocusOut land first — Xephyr's XGrabPointer fails if MC still holds one.
(fn synthesize-xephyr-grab []
  (gears.timer.start_new 0.2 (fn []
                               (awful.spawn [:xdotool :key :ctrl+shift])
                               false)))

(fn stop-detach-poll []
  (when detach-poll-timer
    (detach-poll-timer:stop)
    (set detach-poll-timer nil)))

(fn detach-from-window []
  (when attached?
    (stop-detach-poll)
    (os.remove detach-request-flag)
    (when (and attach-target attach-target.valid)
      (when attach-target-was-hidden?
        ;; we un-minimized it on attach; re-hide so demo-mode invariants hold
        (table.insert hidden-by-demo attach-target)
        (set attach-target.minimized true)))
    (when (and attach-saved-focus attach-saved-focus.valid
               (not attach-saved-focus.minimized))
      (set client.focus attach-saved-focus))
    (when attach-saved-pointer
      (mouse.coords {:x attach-saved-pointer.x :y attach-saved-pointer.y}))
    ;; resume deterministically — detach must never leave the game paused
    (touch-director-resume)
    ;; pointer is back over MC but GLFW only re-grabs on a real button event
    (synthesize-left-click)
    (set attached? false)
    (set attach-target nil)
    (set attach-saved-pointer nil)
    (set attach-saved-focus nil)
    (set attach-target-was-hidden? false)))

;; Alt+F pressed inside Xephyr: the xbindkeys on :2 has touched detach-request.
;; Xephyr still holds the host grab, so first toggle it off with Ctrl+Shift,
;; then once that release flushes hand off to detach-from-window.
(fn handle-detach-request []
  (stop-detach-poll)
  (os.remove detach-request-flag)
  (awful.spawn [:xdotool :key :ctrl+shift])
  (gears.timer.start_new 0.25 (fn [] (detach-from-window) false)))

;; While attached, poll for the detach-request flag. The start_new callback
;; returning false stops the timer; true reschedules it.
(fn start-detach-poll []
  (stop-detach-poll)
  (os.remove detach-request-flag)
  (set detach-poll-timer
       (gears.timer.start_new 0.15
                              (fn []
                                (if (not attached?) false
                                    (file-exists? detach-request-flag) (do
                                                                         (handle-detach-request)
                                                                         false)
                                    true)))))

(fn complete-attach [title]
  (let [xephyr (find-xephyr-client)]
    (when xephyr
      (let [coords (mouse.coords)]
        (set attach-saved-pointer {:x coords.x :y coords.y}))
      (set attach-saved-focus client.focus)
      (set attach-target-was-hidden? xephyr.minimized)
      (when xephyr.minimized
        ;; pull it out of hidden-by-demo so leaving demo-mode doesn't try to
        ;; restore it a second time
        (let [filtered []]
          (each [_ c (ipairs hidden-by-demo)]
            (when (not= c xephyr) (table.insert filtered c)))
          (set hidden-by-demo filtered))
        (set xephyr.minimized false))
      ;; Xephyr must be un-minimized (mapped) to be focusable and to grab, but
      ;; MC is only *maximized*, not in the fullscreen layer — so raising Xephyr
      ;; would lift it over MC onto the desktop. Lower it instead: focus + the
      ;; Ctrl+Shift grab route input regardless of stacking, and it stays
      ;; hidden behind MC.
      (xephyr:lower)
      (set client.focus xephyr)
      (let [g (xephyr:geometry)
            cx (math.floor (+ g.x (/ g.width 2)))
            cy (math.floor (+ g.y (/ g.height 2)))]
        (mouse.coords {:x cx :y cy}))
      ;; firefox/ghostty are inside the :2 server, so awesome can't focus them
      ;; directly. No WM runs on :2, so EWMH windowactivate is a no-op there —
      ;; windowraise + windowfocus (XSetInputFocus) pick the target instead.
      (awful.spawn.with_shell (.. "DISPLAY=:2 xdotool search --limit 1 --name "
                                  (shell-quote (regex-escape title))
                                  " windowraise windowfocus"))
      ;; freeze deterministically — never rely on toggle state here
      (touch-director-freeze)
      ;; confine real input into :2 — Ctrl+Shift toggles Xephyr's own grab
      (synthesize-xephyr-grab)
      (set attach-target xephyr)
      (set attached? true)
      ;; awesome's :0 Alt+F is now masked by Xephyr's grab — poll for the
      ;; detach-request flag the :2 xbindkeys writes instead
      (start-detach-poll))))

(fn try-attach []
  (when (and demo-mode? (not attached?))
    ;; Truncate the response, signal quote-mc, then poll for ~500ms. Quote-mc
    ;; writes either "<title>\n" (target found) or "\n" (no target). We trim
    ;; trailing whitespace; empty = silent no-op.
    (awful.spawn.easy_async_with_shell (.. "dir=\"${XDG_RUNTIME_DIR:-/tmp}/director\"
mkdir -p \"$dir\"
: > \"$dir/attach-response\"
touch \"$dir/attach-request\"
for _ in 1 2 3 4 5 6 7 8 9 10; do
  sleep 0.05
  if [ -s \"$dir/attach-response\" ]; then
    cat \"$dir/attach-response\"
    exit 0
  fi
done")
                                       (fn [stdout _ _ _]
                                         (let [title (trim (or stdout ""))]
                                           (when (not= title "")
                                             (complete-attach title)))))))

(fn attach-toggle []
  (if attached? (detach-from-window) (try-attach)))

;; wintc-taskband --start signals the running instance over D-Bus to toggle
;; the Start menu.
(fn toggle-start-menu []
  (awful.spawn [:wintc-taskband :--start]))

(var globalkeys
     (gears.table.join (awful.key [modkey] :Return
                                  (fn [] (awful.spawn terminal)))
                       (awful.key [modkey] :d
                                  (fn [] (awful.spawn "rofi -show drun")))
                       (awful.key [modkey :Shift] :e awesome.quit)
                       (awful.key [modkey :Shift] :c awesome.restart)
                       (awful.key [modkey] :h
                                  (fn [] (awful.client.focus.bydirection :left)))
                       (awful.key [modkey] :j
                                  (fn [] (awful.client.focus.bydirection :down)))
                       (awful.key [modkey] :k
                                  (fn [] (awful.client.focus.bydirection :up)))
                       (awful.key [modkey] :l
                                  (fn []
                                    (awful.client.focus.bydirection :right)))
                       (awful.key [modkey :Shift] :h
                                  (fn [] (awful.client.swap.bydirection :left)))
                       (awful.key [modkey :Shift] :j
                                  (fn [] (awful.client.swap.bydirection :down)))
                       (awful.key [modkey :Shift] :k
                                  (fn [] (awful.client.swap.bydirection :up)))
                       (awful.key [modkey :Shift] :l
                                  (fn [] (awful.client.swap.bydirection :right)))
                       (awful.key [modkey] :e
                                  (fn []
                                    (awful.layout.set awful.layout.suit.tile)))
                       (awful.key [modkey] :s
                                  (fn []
                                    (awful.layout.set awful.layout.suit.tile.bottom)))
                       (awful.key [modkey] :w
                                  (fn []
                                    (awful.layout.set awful.layout.suit.max)))
                       (awful.key [modkey] :grave
                                  (fn []
                                    (let [s (awful.screen.focused)
                                          t (. s.tags 1)]
                                      (when t (t:view_only)))))
                       (awful.key [modkey :Shift] :grave
                                  awful.tag.history.restore)
                       (awful.key [altkey] :m director-toggle-soft)
                       (awful.key [altkey :Shift] :m director-toggle)
                       (awful.key [altkey] :f attach-toggle)
                       (awful.key [modkey] :Escape toggle-start-menu)))

(for [i 1 4]
  (let [label (tostring i)]
    (set globalkeys
         (gears.table.join globalkeys
                           (awful.key [modkey] label
                                      (fn []
                                        (let [s (awful.screen.focused)
                                              t (. s.tags i)]
                                          (when t (t:view_only)))))
                           (awful.key [modkey :Shift] label
                                      (fn []
                                        (when client.focus
                                          (let [t (. client.focus.screen.tags i)]
                                            (when t
                                              (client.focus:move_to_tag t))))))))))

(root.keys globalkeys)

(set awful.rules.rules
     [{:rule {}
       :properties {:border_width beautiful.border_width
                    :border_color beautiful.border_normal
                    :focus awful.client.focus.filter
                    :raise true
                    :keys clientkeys
                    :buttons clientbuttons
                    :screen awful.screen.preferred
                    :placement (+ awful.placement.no_overlap
                                  awful.placement.no_offscreen)
                    :titlebars_enabled true}}
      {:rule_any {:class [:Pavucontrol :Nm-connection-editor]}
       :properties {:floating true}}
      ;; Xephyr hosts the nested :2 X server whose framebuffer the Quote-MC
      ;; monitor blocks capture (firefox / ghostty render there). It's
      ;; plumbing, not a window to interact with — drop its chrome and keep it
      ;; off the taskband. The `manage` handler parks it on the 2nd monitor (or
      ;; minimizes it if there is only one), out of the maximized MC's way.
      {:rule {:class :Xephyr}
       :properties {:skip_taskbar true
                    :focusable false
                    :titlebars_enabled false
                    :border_width 0}}
      ;; wintc-taskband's multi-monitor handling is broken: it places its DOCK
      ;; window at virtual-screen (0,0) and sets _NET_WM_STRUT_PARTIAL bottom
      ;; to (virt_height - DP-1_height). Anchor it to the bottom of screen 1
      ;; (DP-1) and set a sane 30px strut. Match :type "dock" so this rule
      ;; doesn't fire for the start menu popup (which shares the class).
      {:rule {:class :Wintc-taskband :type :dock}
       :properties {:titlebars_enabled false
                    :border_width 0
                    :focusable false
                    :focus false}
       :callback (fn [c]
                   (let [s (. screen 1)
                         g s.geometry
                         h 30]
                     (set c.x g.x)
                     (set c.y (+ g.y g.height (- h)))
                     (set c.width g.width)
                     (set c.height h)
                     (c:struts {:bottom h :left 0 :right 0 :top 0})))}
      ;; Start menu popup: type=popup_menu, class=Wintc-taskband. Wintc creates
      ;; it as a GTK toplevel that hides itself on focus-out-event
      ;; (shelldpa/api.c:152). If awesome's generic {:rule {}} catches it, the
      ;; no_overlap placement, titlebar, and focus filter all interfere — and
      ;; if awesome refuses to focus the popup at all, the focus-out handler
      ;; fires immediately, so the menu dismisses the moment the pointer moves.
      ;; Force the popup to be focus-eligible, no-op placement, drop chrome,
      ;; and stay on top so wintc's own logic runs cleanly. The (fn [c] c)
      ;; identity callbacks defeat the inherited :focus / :placement values
      ;; without breaking awesome's rule merge — do not "clean up" to nil.
      {:rule {:class :Wintc-taskband :type :popup_menu}
       :properties {:titlebars_enabled false
                    :border_width 0
                    :focusable true
                    :focus (fn [c] c)
                    :ontop true
                    :skip_taskbar true
                    :placement (fn [c] c)}}
      ;; focusable stays true to align with LWJGL2's X11 grab (prevents stuck keys).
      ;; size_hints_honor false: LWJGL2 / Prism's JVM reports its window's default
      ;; size (e.g. 854x480) as a WM_NORMAL_HINTS program-specified size, which
      ;; awesome would otherwise clamp our screen.geometry call back to.
      ;; honor_workarea true: MC's bottom stops at the taskband's top edge instead
      ;; of being covered by it; wintc-taskband sets _NET_WM_STRUT_PARTIAL.
      ;; Prism's main window (class org-prismlauncher-EntryPoint) is the host that
      ;; backgrounds the launched minecraft; treat both the same.
      ;; placement override is needed because the generic {:rule {}} rule above sets
      ;; placement = no_overlap + no_offscreen, which would re-clamp our resize.
      {:rule_any {:class [:Minecraft :org-prismlauncher-EntryPoint]}
       :properties {:floating true
                    :sticky true
                    :below true
                    :ontop false
                    :focusable true
                    :fullscreen false
                    :border_width 0
                    :screen 1
                    :size_hints_honor false
                    :skip_taskbar true
                    :titlebars_enabled false
                    :placement (fn [c]
                                 (awful.placement.maximize c
                                                           {:honor_workarea true}))}
       :callback (fn [c]
                   (let [apply (fn []
                                 (when c.valid
                                   (set c.size_hints_honor false)
                                   (awful.placement.maximize c
                                                             {:honor_workarea true})))]
                     (apply)
                     ;; Prism/LWJGL2 may resize after the GL context comes up;
                     ;; re-pin once the X event loop settles.
                     (gears.timer.delayed_call apply)
                     (gears.timer.start_new 1 (fn [] (apply) false))))}])

(client.connect_signal :manage
                       (fn [c]
                         (when (and awesome.startup
                                    (not c.size_hints.user_position)
                                    (not c.size_hints.program_position))
                           (awful.placement.no_offscreen c))
                         ;; The Xephyr :2 host window is plumbing (content is
                         ;; mirrored into MC, input goes via Alt+F) and must
                         ;; never sit over the maximized MC on screen 1. With a
                         ;; 2nd monitor, park it there — visible but out of the
                         ;; way. Single-monitor: minimize it (the awful.rules
                         ;; `minimized` doesn't reliably stick, and a delayed
                         ;; re-assert beats autofocus un-minimizing it).
                         (when (xephyr-client? c)
                           (set c.skip_taskbar true)
                           (let [s2 (. screen 2)]
                             (if s2
                                 (do
                                   (set c.minimized false)
                                   (set c.screen s2)
                                   (set c.x s2.geometry.x)
                                   (set c.y s2.geometry.y))
                                 (do
                                   (set c.minimized true)
                                   (gears.timer.delayed_call (fn []
                                                               (when c.valid
                                                                 (set c.minimized
                                                                      true))))))))))

;;; xset r off: X11 fake KeyRelease autorepeat trips LWJGL2's pause-menu ESC.
;;; Spawn wintc-taskband first so its systray claims the slot before
;;; nm-applet / pasystray try to XEMBED.
;;; xcape: emit Super+Escape on a Super tap (Super held + released with no
;;; other key). Super+Escape is bound below to toggle-start-menu.
(when awesome.startup
  ;; stylix sets a system-wide GTK theme; override so the taskband renders Luna.
  (awful.spawn.with_shell "GTK_THEME='Windows XP style (Blue)' wintc-taskband")
  (awful.spawn "xset r off")
  (awful.spawn "xcape -e Super_L=Super_L|Escape")
  (awful.spawn :nm-applet)
  (awful.spawn :pasystray)
  (awful.spawn.with_shell "quote-mc-launch >/tmp/quote-mc-launch.log 2>&1"))
