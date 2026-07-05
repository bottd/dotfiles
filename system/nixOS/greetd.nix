{ config, lib, pkgs, username, features, autologin, ... }:
let
  de = features.desktopEnvironment;
  sessionCommand =
    if de == "sway" then "${pkgs.sway}/bin/sway"
    else if de == "niri" then "${config.programs.niri.package}/bin/niri-session"
    else throw "greetd: unsupported desktopEnvironment: ${de}";
in
{
  services.greetd.enable = true;

  programs.regreet.enable = !autologin;

  services.greetd.settings.default_session = lib.mkIf autologin {
    command = sessionCommand;
    user = username;
  };
}
