{ ...
}: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      monitor = eDP-1, 1600x2560, 0x0, 1, transform, 3
    '';
  };
}
