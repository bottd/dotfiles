{
  lib,
  pkgs,
  username,
  paths,
  host,
  ...
}: let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
in {
  imports = [
    "${paths.homeCommon}/default.nix"

    # Platform-specific configurations
    (
      if isLinux
      then "${paths.homeLinux}/default.nix"
      else
        (
          if isDarwin
          then "${paths.homeDarwin}/default.nix"
          else builtins.abort "Unsupported platform"
        )
    )

    # Host-specific configurations if they exist
    (
      if builtins.pathExists "${paths.hosts}/${host.hostName}/home.nix"
      then "${paths.hosts}/${host.hostName}/home.nix"
      else {}
    )
  ];

  home.username = username;

  #WARNING: Don't change this without reading docs
  home.stateVersion = "24.11";
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
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
