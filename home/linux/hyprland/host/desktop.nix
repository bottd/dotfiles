{
  config,
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      monitor = DP-1, 2560x1440, 2560x0, 1, transform, 1
      monitor = DP-3, 2560x1440, 0x0, 1
    '';
  };
}
