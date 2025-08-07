{ lib, pkgs, username, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  home = {
    inherit username;
    stateVersion = "25.05";
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
