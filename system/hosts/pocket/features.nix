# Pocket-specific feature configuration
{
  config,
  lib,
  ...
}: {
  # Enable pocket-specific features
  features = {
    desktop = {
      enable = true;
      wayland = true;
      hyprland = true;
      gaming = false; # Not a gaming machine
    };

    dev = {
      enable = true;
      python = true;
      rust = false;
      node = false; # Minimal development environment
      go = false;
    };

    hardware = {
      nvidia = false;
      intel = true; # Pocket has Intel CPU/GPU
      amd = false;
      bluetooth = true;
      printing = false;
      virtualisation = false; # Save resources on portable
    };

    security = {
      yubikey = true;
      ssh = true;
      firewall = true;
    };
  };
}
