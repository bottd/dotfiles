{ lib, pkgs, username, versions, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  home = {
    inherit username;
    stateVersion = versions.home;
    homeDirectory = if isLinux then "/home/${username}" else "/Users/${username}";
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = isLinux;
  xdg.enable = true;

  nix = {
    package = lib.mkForce pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
