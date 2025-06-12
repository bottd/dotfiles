#!/usr/bin/env bb

(require '[babashka.process :refer [shell]])

;; Set light theme
(shell "gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'")
(shell "gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Latte-Standard-Blue-Light'")
(shell "gsettings set org.gnome.desktop.interface icon-theme 'Papirus'")
(shell "gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-latte-light-cursors'")

;; Switch Hyprland theme to light (if config exists)
(when (.exists (java.io.File. (str (System/getProperty "user.home") "/.config/hypr/latte.conf")))
  (shell "ln -sf ~/.config/hypr/latte.conf ~/.config/hypr/current-theme.conf")
  (try
    (shell "hyprctl reload")
    (catch Exception _e
      (println "Could not reload Hyprland config"))))