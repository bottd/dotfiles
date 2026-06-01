;; Widgets and wibar for Awesome WM

(local gears (require :gears))
(local awful (require :awful))
(local wibox (require :wibox))
(local beautiful (require :beautiful))

(local M {})

;; Textclock widget
(local textclock (wibox.widget.textclock))

;; Create taglist buttons
(local taglist-buttons
       (gears.table.join (awful.button [] 1 (fn [t] (t:view_only)))
                         (awful.button [_G.modkey] 1
                                       (fn [t]
                                         (when client.focus
                                           (client.focus:move_to_tag t))))
                         (awful.button [] 3 awful.tag.viewtoggle)
                         (awful.button [_G.modkey] 3
                                       (fn [t]
                                         (when client.focus
                                           (client.focus:toggle_tag t))))
                         (awful.button [] 4
                                       (fn [t] (awful.tag.viewnext t.screen)))
                         (awful.button [] 5
                                       (fn [t] (awful.tag.viewprev t.screen)))))

;; Create tasklist buttons
(local tasklist-buttons
       (gears.table.join (awful.button [] 1
                                       (fn [c]
                                         (if (= c client.focus)
                                             (set c.minimized true)
                                             (c:emit_signal "request::activate"
                                                            :tasklist
                                                            {:raise true}))))
                         (awful.button [] 3
                                       (fn []
                                         (awful.menu.client_list {:theme {:width 250}})))
                         (awful.button [] 4
                                       (fn [] (awful.client.focus.byidx 1)))
                         (awful.button [] 5
                                       (fn [] (awful.client.focus.byidx -1)))))

(fn M.setup-wibar [launcher]
  ;; Create wibar for each screen
  (awful.screen.connect_for_each_screen (fn [s]
                                          ;; Create tags
                                          (awful.tag [:1
                                                      :2
                                                      :3
                                                      :4
                                                      :5
                                                      :6
                                                      :7
                                                      :8
                                                      :9]
                                                     s
                                                     (. awful.layout.layouts 1))
                                          ;; Create promptbox
                                          (set s.mypromptbox
                                               (awful.widget.prompt))
                                          ;; Create layoutbox
                                          (set s.mylayoutbox
                                               (awful.widget.layoutbox s))
                                          (s.mylayoutbox:buttons (gears.table.join (awful.button []
                                                                                                 1
                                                                                                 (fn []
                                                                                                   (awful.layout.inc 1)))
                                                                                   (awful.button []
                                                                                                 3
                                                                                                 (fn []
                                                                                                   (awful.layout.inc -1)))
                                                                                   (awful.button []
                                                                                                 4
                                                                                                 (fn []
                                                                                                   (awful.layout.inc 1)))
                                                                                   (awful.button []
                                                                                                 5
                                                                                                 (fn []
                                                                                                   (awful.layout.inc -1)))))
                                          ;; Create taglist
                                          (set s.mytaglist
                                               (awful.widget.taglist {:screen s
                                                                      :filter awful.widget.taglist.filter.all
                                                                      :buttons taglist-buttons}))
                                          ;; Create tasklist
                                          (set s.mytasklist
                                               (awful.widget.tasklist {:screen s
                                                                       :filter awful.widget.tasklist.filter.currenttags
                                                                       :buttons tasklist-buttons}))
                                          ;; Create wibox
                                          (set s.mywibox
                                               (awful.wibar {:position :top
                                                             :screen s}))
                                          ;; Add widgets
                                          (s.mywibox:setup {:layout wibox.layout.align.horizontal
                                                            1 {:layout wibox.layout.fixed.horizontal
                                                               1 launcher
                                                               2 s.mytaglist
                                                               3 s.mypromptbox}
                                                            2 s.mytasklist
                                                            3 {:layout wibox.layout.fixed.horizontal
                                                               1 (wibox.widget.systray)
                                                               2 textclock
                                                               3 s.mylayoutbox}}))))

M
