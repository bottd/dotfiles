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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # OOM configuration to prevent build failures
  systemd = {
    # Create a separate slice for nix-daemon that is
    # memory-managed by the userspace systemd-oomd killer
    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
    services."nix-daemon".serviceConfig.Slice = "nix-daemon.slice";

    # If a kernel-level OOM event does occur, prefer killing nix-daemon
    services."nix-daemon".serviceConfig.OOMScoreAdjust = 1000;
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # X11 keyboard configuration
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # System packages for desktop
  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
    mako
    pavucontrol
    helvum
    ghostty
  ];

  # Use this fixed version - do not change without reading docs
  system.stateVersion = "24.11";
}
