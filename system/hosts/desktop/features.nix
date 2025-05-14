# Desktop-specific feature configuration
{
  config,
  lib,
  ...
}: {
  # Enable desktop-specific features
  features = {
    desktop = {
      enable = true;
      wayland = true;
      hyprland = true;
      gaming = true; # Gaming PC
    };

    dev = {
      enable = true;
      python = true;
      rust = true;
      node = true; # Full development environment
      go = true;
    };

    hardware = {
      nvidia = true; # Desktop has NVIDIA GPU
      amd = true; # Desktop has AMD CPU
      bluetooth = true;
      printing = true;
      virtualisation = true; # Enable virtualization for development
    };

    security = {
      yubikey = true; # Use YubiKey for authentication
      ssh = true;
      firewall = true;
    };
  };
}
