{ ...
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
      devices = [ "nodev" ];
      efiSupport = true;
      enable = false;
    };
  };

  # Any host-specific settings can go here

  # Use this fixed version - do not change without reading docs
  system.stateVersion = "24.11";

  # https://discourse.nixos.org/t/nix-build-ate-my-ram/35752
  # OOM configuration:
  systemd = {
    # Create a separate slice for nix-daemon that is
    # memory-managed by the userspace systemd-oomd killer
    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
    services."nix-daemon".serviceConfig.Slice = "nix-daemon.slice";

    # If a kernel-level OOM event does occur anyway,
    # strongly prefer killing nix-daemon child processes
    services."nix-daemon".serviceConfig.OOMScoreAdjust = 1000;
  };
}
