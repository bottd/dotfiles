{
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;

    withUWSM = true;
    xwayland.enable = true;
  };
  programs.hyprlock.enable = true;
  programs.uwsm.enable = true;

  environment.systemPackages = [
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  hardware = {
    opengl.enable = true;
  };
}
