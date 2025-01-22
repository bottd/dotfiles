{config, pkgs, ... }:
{
  # hint Electron apps to use Wayland
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # software needed for hyprland
  # https://wiki.hyprland.org/Useful-Utilities/Must-have/
  home.packages = with pkgs; [
    # notification daemon
    swaynotificationcenter
  ];
  home.file = {
    ".config/hyprland/hyprland.conf" = {
      source = config.lib.meta.createSymlink("home/linux/hyprland/hyprland.conf");
      recursive = true;
    }
  }
}
