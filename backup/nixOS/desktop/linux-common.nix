# Linux-specific common settings from new module structure
{
  lib,
  pkgs,
  ...
}: {
  # Enable basic services commonly used on Linux
  networking.networkmanager.enable = true;

  # Additional settings can be copied here as needed
  # This is a wrapper to import settings without path resolution issues
}
