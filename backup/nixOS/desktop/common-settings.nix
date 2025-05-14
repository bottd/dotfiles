# Common settings wrapper module - mirroring system/modules/common
# This approach duplicates content from new structure to avoid path issues
{
  lib,
  pkgs,
  config,
  ...
}: let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  # Common settings that work on both platforms
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      auto-optimise-store = true;
    };

    # Darwin doesn't support all the same gc options
    gc =
      if isLinux
      then {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      }
      else {
        automatic = true;
        interval = {
          Weekday = 0;
          Hour = 2;
          Minute = 0;
        };
      };
  };

  # Time and localization (works on both platforms)
  time.timeZone = "America/Chicago";

  # Linux-specific imports
  imports =
    if isLinux
    then [
      # Linux-specific settings - integrated directly in this wrapper
      ./common-linux.nix
    ]
    else [];

  # Common packages for both platforms
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];
}
