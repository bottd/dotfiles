# Features module for configuring system capabilities
{
  lib,
  config,
  ...
}: {
  options.features = {
    # Desktop environment features
    desktop = {
      enable = lib.mkEnableOption "Enable desktop environment features";
      wayland = lib.mkEnableOption "Enable Wayland support";
      hyprland = lib.mkEnableOption "Enable Hyprland window manager";
      gaming = lib.mkEnableOption "Enable gaming-related packages and settings";
    };

    # Development features
    dev = {
      enable = lib.mkEnableOption "Enable development tools";
      python = lib.mkEnableOption "Enable Python development tools";
      rust = lib.mkEnableOption "Enable Rust development tools";
      node = lib.mkEnableOption "Enable Node.js development tools";
      go = lib.mkEnableOption "Enable Go development tools";
    };

    # Hardware features
    hardware = {
      nvidia = lib.mkEnableOption "Enable NVIDIA drivers and related settings";
      intel = lib.mkEnableOption "Enable Intel drivers and related settings";
      amd = lib.mkEnableOption "Enable AMD drivers and related settings";
      bluetooth = lib.mkEnableOption "Enable Bluetooth support";
      printing = lib.mkEnableOption "Enable printing support";
      virtualisation = lib.mkEnableOption "Enable virtualization tools";
    };

    # Security features
    security = {
      yubikey = lib.mkEnableOption "Enable YubiKey support";
      ssh = lib.mkEnableOption "Enable SSH server and client";
      firewall = lib.mkEnableOption "Enable firewall with default settings";
    };
  };

  # Default values
  config = {
    # NixOS defaults
    features.desktop = lib.mkIf (lib.strings.hasSuffix "linux" config.nixpkgs.system) {
      enable = true;
      wayland = true;
      hyprland = true;
      gaming = false;
    };

    # Common defaults for all systems
    features.dev = {
      enable = true;
      python = false;
      rust = false;
      node = false;
      go = false;
    };

    # Hardware defaults based on host
    features.hardware = {
      nvidia = false;
      intel = false;
      amd = false;
      bluetooth = true;
      printing = false;
      virtualisation = false;
    };

    # Security defaults
    features.security = {
      yubikey = false;
      ssh = true;
      firewall = true;
    };
  };
}
