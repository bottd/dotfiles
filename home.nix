{
  lib,
  pkgs,
  username,
  ...
}: let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
in {
  home.username = username;

  #WARNING: Don't change this without reading docs
  home.stateVersion = "25.05";
  programs.home-manager.enable = true; # Let home manager manage itself

  home.homeDirectory =
    if isLinux
    then "/home/${username}"
    else if isDarwin
    then "/Users/${username}"
    else unsupported;

  fonts.fontconfig.enable = isLinux;
  # fonts.fontconfig.enable = true; # Enable fonts

  xdg.enable = true;
  nix = {
    # Configure the Nix package manager itself
    # TODO: Remove use of lib.mkForce
    package = lib.mkForce pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
