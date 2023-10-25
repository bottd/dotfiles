(local wezterm (require "wezterm"))

;; TODO: `utf8` not working in Fennel?
;;  
;; The filled in variant of the < symbol
; (local SOLID-LEFT-ARROW (_G.utf8.char 0xe0b0))
;; The filled in variant of the > symbol
; (local SOLID-RIGHT-ARROW (_G.utf8.char 0xe0b0))
; (local SOLID-LEFT-CIRCLE (_G.utf8.char 0xE3))

(local light (require "theme/rose-pine-dawn"))
(local dark (require "theme/rose-pine-moon"))


(fn scheme_for_appearance [appearance]
  (if (appearance:find "Dark")
    [(dark.colors) (dark.window_frame)]
    [(light.colors) (light.window_frame)]
  ))

(wezterm.on "window-config-reloaded" (fn [window pane]
  (local overrides (or (window:get_config_overrides) {}))
  (local appearance (window:get_appearance))
  (local [colors window_frame] (scheme_for_appearance appearance))
  (if (not= overrides.colors colors)
    (tset overrides :colors colors)
    (tset overrides :window_frame window_frame)
    (window:set_config_overrides overrides)
  )
))
{
  :colors (light.colors)
  :window_frame (light.window_frame)
  :font (wezterm.font "MonoLisa Nerd Font")
  :font_size 13
  :hide_tab_bar_if_only_one_tab true
  :tab_bar_at_bottom true
  :use_fancy_tab_bar false
  :leader {
    :key "a"
    :mods "CTRL"
    :timeout_miliseconds 1000
  }
  :keys [
    {
      :key "/"
      :mods "LEADER"
      :action (wezterm.action.SplitHorizontal {
        :domain "CurrentPaneDomain"
      })
    }
    {
      :key "-"
      :mods "LEADER"
      :action (wezterm.action.SplitVertical {
        :domain "CurrentPaneDomain"
      })
    }
  ]
}
