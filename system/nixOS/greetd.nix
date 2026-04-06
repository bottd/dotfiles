{ config, lib, pkgs, username, desktopEnvironment, autologin, ... }:
let
  sessionCommand =
    if desktopEnvironment == "plasma" then "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland"
    else if desktopEnvironment == "niri" then "${config.programs.niri.package}/bin/niri-session"
    else if desktopEnvironment == "sway" then "${pkgs.sway}/bin/sway"
    else throw "greetd: unsupported desktopEnvironment: ${desktopEnvironment}";
in
{
  services.greetd.enable = true;

  programs.regreet.enable = !autologin;

  services.greetd.settings.default_session = lib.mkIf autologin {
    command = sessionCommand;
    user = username;
  };
}
