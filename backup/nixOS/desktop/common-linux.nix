# Linux-specific common settings - mirroring system/modules/common/linux
# This approach duplicates content from new structure to avoid path issues
{
  lib,
  pkgs,
  ...
}: {
  # Locale settings specific to Linux
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable basic services commonly used on Linux
  networking.networkmanager.enable = true;
}
