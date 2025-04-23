{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
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
    };
  };

  # home.pointerCursor = {
  #   name = "catppuccin-mocha-blue-cursors";
  #   package = pkgs.catppuccin-cursors.mochaBlue;
  #   size = 24;
  #   hyprcursor.enable = true;
  #   gtk.enable = true;
  #   x11.enable = true;
  # };
}
