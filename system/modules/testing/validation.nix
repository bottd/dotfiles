# Configuration validation module for CI testing
{
  config,
  lib,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Get the module configurations
  userCfg = moduleSystem.getModuleConfig config.sysConfig.user;
  hardwareCfg = moduleSystem.getModuleConfig config.sysConfig.hardware;
  desktopCfg = moduleSystem.getModuleConfig config.sysConfig.desktop;
  securityCfg = moduleSystem.getModuleConfig config.sysConfig.security;
in {
  # Assertions for validating configuration
  assertions = [
    # User configuration
    {
      assertion = userCfg.name != null && userCfg.name != "";
      message = "User name must be set.";
    }

    # Hardware configuration
    {
      assertion = hardwareCfg.cpuType != "unknown" || config.system.isContainer or false;
      message = "CPU type must be specified (intel, amd, or arm).";
    }
    {
      assertion = hardwareCfg.gpuType != "unknown" || config.system.isContainer or false;
      message = "GPU type must be specified (nvidia, amd, intel, or apple).";
    }

    # Desktop configuration
    {
      assertion = !desktopCfg.enable || desktopCfg.useWayland || desktopCfg.useX11;
      message = "If desktop is enabled, either Wayland or X11 must be enabled.";
    }
    {
      assertion = !desktopCfg.useHyprland || desktopCfg.useWayland;
      message = "Hyprland requires Wayland to be enabled.";
    }
    {
      assertion = !(desktopCfg.useGnome && desktopCfg.useKDE);
      message = "Cannot enable both GNOME and KDE simultaneously.";
    }

    # Security configuration
    {
      assertion = !config.networking.networkmanager.enable || securityCfg.enableFirewall;
      message = "Firewall should be enabled when NetworkManager is enabled.";
    }
  ];

  # Warnings for potential issues
  warnings = lib.flatten [
    # Hardware warnings
    (lib.optional (hardwareCfg.virtualization && hardwareCfg.cpuType == "intel" && !config.security.virtualisation.flushL1DataCache)
      "Intel CPU with virtualization enabled should have security.virtualisation.flushL1DataCache set.")

    # Desktop warnings
    (lib.optional (desktopCfg.enable && !hardwareCfg.opengl)
      "Desktop environment enabled but hardware.opengl is not enabled.")

    # Security warnings
    (lib.optional (!securityCfg.enableFirewall && !config.system.isContainer or false)
      "Firewall is disabled. Consider enabling it for better security.")
  ];
}
