{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        fennel
        lgi
      ];
    };
  };

  services.displayManager.defaultSession = "none+awesome";

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    luaPackages.fennel
    rofi
    picom
    feh
    maim
    xclip
    xdotool
    playerctl
    brightnessctl
    networkmanagerapplet
    pasystray
  ];
}
