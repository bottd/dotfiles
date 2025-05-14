{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    # Explicitly set the device to install bootloader to
    grub = {
      devices = ["nodev"];
      efiSupport = true;
      enable = false;
    };
  };

  # Any host-specific settings can go here

  # Use this fixed version - do not change without reading docs
  system.stateVersion = "24.11";
}
