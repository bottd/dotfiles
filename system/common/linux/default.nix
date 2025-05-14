# Linux-specific common settings
{
  lib,
  pkgs,
  ...
}: {
  # Note: Locale settings are now defined in base/default.nix
  # Note: allowUnfree setting is now defined in base/default.nix

  # Enable basic services commonly used on Linux
  networking.networkmanager.enable = true;

  # Additional Linux-specific packages and services can be added here
}
