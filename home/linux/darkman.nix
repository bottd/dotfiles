{ ...
}: {
  xdg.configFile."xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    org.freedesktop.impl.portal.Settings=darkman
  '';

  services.darkman = {
    enable = true;

    settings = {
      # Chicago coordinates
      lat = 41.9;
      lng = -87.6;
      dbusserver = true;
      portal = true;
    };

    darkModeScripts = {
      theme = ''
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Blue-Dark'
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
        gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-dark-cursors'

        if [ -f "$HOME/.config/hypr/mocha.conf" ]; then
          ln -sf ~/.config/hypr/mocha.conf ~/.config/hypr/current-theme.conf
          if command -v hyprctl >/dev/null 2>&1; then
            hyprctl reload || echo "Could not reload Hyprland config"
          fi
        fi
      '';
    };

    lightModeScripts = {
      theme = ''
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Latte-Standard-Blue-Light'
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
        gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-latte-light-cursors'

        if [ -f "$HOME/.config/hypr/latte.conf" ]; then
          ln -sf ~/.config/hypr/latte.conf ~/.config/hypr/current-theme.conf
          if command -v hyprctl >/dev/null 2>&1; then
            hyprctl reload || echo "Could not reload Hyprland config"
          fi
        fi
      '';
    };
  };

}
