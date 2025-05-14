# Wayland-specific common settings for Linux systems
{
  pkgs,
  lib,
  ...
}: {
  # Common X11/XKB settings across wayland hosts
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Common wayland utilities
  environment.systemPackages = with pkgs; [
    # Screen capture tools
    grim
    slurp

    # Clipboard manager
    wl-clipboard

    # Notification daemon
    mako

    # Audio control
    pavucontrol
    helvum

    # Terminal
    ghostty
  ];

  # Wayland portal
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
