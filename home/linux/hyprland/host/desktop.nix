{ ...
}: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      monitor = DP-3, 2560x1440, 2560x0, 1, transform, 3
      monitor = DP-1, 2560x1440@170, 0x0, 1
    '';
  };
}
