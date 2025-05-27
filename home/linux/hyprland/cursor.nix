{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    pkgs.hyprlandPlugins.hypr-dynamic-cursors
  ];

  wayland.windowManager.hyprland = {
    extraConfig = ''
      env = HYPRCURSOR_THEME,catppuccin-mocha-mauve-cursors
      env = HYPRCURSOR_SIZE,24
      env = XCURSOR_THEME,catppuccin-mocha-mauve-cursors
      env = XCURSOR_SIZE,24
    '';
    settings = {
      "plugin:dynamic-cursors" = {
        enabled = true;
        mode = "tilt";
      };
    };
  };
}
