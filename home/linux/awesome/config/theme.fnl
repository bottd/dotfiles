;; Theme configuration for Awesome WM

(local beautiful (require :beautiful))
(local gears (require :gears))

(local M {})

(fn M.init []
  ;; Initialize with default theme as base
  (beautiful.init (.. (gears.filesystem.get_themes_dir) :default/theme.lua))
  ;; Override with custom values
  (set beautiful.font "monospace 10")
  (set beautiful.useless_gap 4)
  (set beautiful.border_width 2)
  (set beautiful.border_normal "#444444")
  (set beautiful.border_focus "#6699cc")
  (set beautiful.bg_normal "#1a1a1a")
  (set beautiful.bg_focus "#2a2a2a")
  (set beautiful.bg_urgent "#ff6666")
  (set beautiful.fg_normal "#cccccc")
  (set beautiful.fg_focus "#ffffff")
  (set beautiful.fg_urgent "#ffffff")
  ;; Taglist
  (set beautiful.taglist_bg_focus "#6699cc")
  (set beautiful.taglist_fg_focus "#ffffff")
  ;; Tasklist
  (set beautiful.tasklist_bg_focus "#2a2a2a")
  ;; Wibar
  (set beautiful.wibar_bg "#1a1a1aee")
  (set beautiful.wibar_fg "#cccccc")
  ;; Wallpaper
  (set beautiful.wallpaper nil))

M
