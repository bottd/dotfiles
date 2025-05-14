# MacBook-specific feature configuration
{
  config,
  lib,
  ...
}: {
  # Enable macbook-specific features
  features = {
    desktop = {
      enable = false; # macOS handles desktop environment
      wayland = false;
      hyprland = false;
      gaming = false;
    };

    dev = {
      enable = true;
      python = true;
      rust = true;
      node = true;
      go = false;
    };

    hardware = {
      nvidia = false;
      intel = false;
      amd = false; # Apple Silicon
      bluetooth = true;
      printing = true;
      virtualisation = true;
    };

    security = {
      yubikey = true;
      ssh = true;
      firewall = true;
    };
  };
}
