{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    pkgs.hyprlandPlugins.hypr-dynamic-cursors
    catppuccin-cursors
  ];

  wayland.windowManager.hyprland = {
    extraConfig = ''
      env = HYPRCURSOR_THEME,catppuccin-mocha-blue-cursors
      env = HYPRCURSOR_SIZE,24
      env = XCURSOR_THEME,catppuccin-mocha-blue-cursors
      env = XCURSOR_SIZE,24
    '';
    settings = {
      "plugin:dynamic-cursors" = {
        enabled = true;
        mode = "tilt";
      };
    };
  };
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaBlue;
    name = "Catppuccin Mocha Blue";
    size = 24;
  };
}
