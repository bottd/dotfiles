(local wezterm (require :wezterm))

;; TODO: `utf8` not working in Fennel?
;;  
;; The filled in variant of the < symbol
; (local SOLID-LEFT-ARROW (_G.utf8.char 0xe0b0))
;; The filled in variant of the > symbol
; (local SOLID-RIGHT-ARROW (_G.utf8.char 0xe0b0))
; (local SOLID-LEFT-CIRCLE (_G.utf8.char 0xE3))

(fn get_appearance []
  (if wezterm.gui
      (string.lower (wezterm.gui.get_appearance)) :dark))

(fn scheme_for_appearance []
  (let [appearance (get_appearance)]
    (if (appearance:find :dark) "Catppuccin Mocha" "Catppuccin Latte")))

(wezterm.on :window-config-reloaded
            (fn [window pane]
              (local overrides (or (window:get_config_overrides) {}))
              (local scheme (scheme_for_appearance))
              (when (not= overrides.color_scheme scheme)
                (tset overrides :color_scheme scheme)
                (tset overrides :set_environment_variables
                      {:WINDOW_APPEARANCE (get_appearance)})
                (window:set_config_overrides overrides))))

{:color_scheme (scheme_for_appearance)
 :default_prog [:/opt/homebrew/bin/nu]
 :set_environment_variables {:WINDOW_APPEARANCE (get_appearance)
                             :XDG_CONFIG_HOME (.. (os.getenv :HOME) :/.config)}
 :font (wezterm.font "MonoLisa Variable")
 :font_size 13
 :hide_tab_bar_if_only_one_tab true
 :tab_bar_at_bottom true
 :use_fancy_tab_bar false
 :leader {:key :a :mods :CTRL :timeout_miliseconds 1000}
 :keys [{:key "/"
         :mods :LEADER
         :action (wezterm.action.SplitHorizontal {:domain :CurrentPaneDomain})}
        {:key "-"
         :mods :LEADER
         :action (wezterm.action.SplitVertical {:domain :CurrentPaneDomain})}]
 :window_decorations :RESIZE}

