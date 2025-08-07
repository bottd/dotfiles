{ pkgs, ... }:

{
  programs.niri.enable = true;

  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;
  programs.waybar.enable = true;

  services.mako.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome-agent.enable = true;
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    swaybg
    grim
    slurp
    wl-clipboard
    xwayland-satellite
    wlr-randr
  ];
}
