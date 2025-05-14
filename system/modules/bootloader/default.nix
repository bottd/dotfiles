# Common bootloader settings for NixOS systems
{
  pkgs,
  lib,
  ...
}: {
  # Standard systemd-boot EFI configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
