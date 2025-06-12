#!/usr/bin/env bb

(require '[babashka.process :refer [shell]])

;; Set dark theme
(shell "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
(shell "gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Blue-Dark'")
(shell "gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'")
(shell "gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-dark-cursors'")

;; Switch Hyprland theme to dark (if config exists)
(when (.exists (java.io.File. (str (System/getProperty "user.home") "/.config/hypr/mocha.conf")))
  (shell "ln -sf ~/.config/hypr/mocha.conf ~/.config/hypr/current-theme.conf")
  (try
    (shell "hyprctl reload")
    (catch Exception _e
      (println "Could not reload Hyprland config"))))
