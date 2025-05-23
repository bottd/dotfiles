{ lib
, pkgs
, username
, ...
}:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
in
{
  imports = [ ];

  home.username = username;

  #WARNING: Don't change this without reading docs
  home.stateVersion = "25.05";
  # Let home manager manage itself
  programs.home-manager.enable = true;

  home.homeDirectory =
    if isLinux
    then "/home/${username}"
    else if isDarwin
    then "/Users/${username}"
    else unsupported;

  fonts.fontconfig.enable = isLinux;

  xdg.enable = true;
  nix = {
    # Configure the Nix package manager itself
    package = lib.mkForce pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
