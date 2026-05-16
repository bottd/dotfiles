{ config, lib, pkgs, username, features, autologin, ... }:
let
  de = features.desktopEnvironment;
  sessionCommand = {
    plasma = "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland";
    niri = "${config.programs.niri.package}/bin/niri-session";
    sway = "${pkgs.sway}/bin/sway";
  }.${de} or (throw "greetd: unsupported desktopEnvironment: ${de}");
in
{
  services.greetd.enable = true;

  programs.regreet.enable = !autologin;

  services.greetd.settings.default_session = lib.mkIf autologin {
    command = sessionCommand;
    user = username;
  };
}
