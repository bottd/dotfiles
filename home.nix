{
  lib,
  pkgs,
  username,
  ...
}: let
  unsupported = builtins.abort "Unsupported platform";
in {
  home.username = username;

  #WARNING: Don't change this without reading docs
  home.stateVersion = "24.11";
  # Let home manager manage itself
  programs.home-manager.enable = true;

  home.homeDirectory = then "/home/${username}";

  fonts.fontconfig.enable = true;
  xdg.enable = true;
  nix = {
    package = lib.mkForce pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
