{ pkgs, ... }:
{
  boot = {
    kernelParams = [
      # Disable fan on AC power - https://nixos.wiki/wiki/GPD_Pocket
      "gpd-pocket-fan.speed_on_ac=0"

      # General power saving
      "ahci.mobile_lpm_policy=3"
      "pcie_aspm=force"
    ];

    kernelModules = [
      "gpd-pocket-fan"
    ];

    # Less aggressive fan curve - https://github.com/stockmind/gpd-pocket-ubuntu-respin/issues/46
    # temp_limits: 65°C, 75°C, 80°C (default: 55°C, 60°C, 65°C)
    extraModprobeConfig = ''
      options gpd-pocket-fan temp_limits=65000,75000,80000 hysteresis=5000 speed_on_ac=0
    '';
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Disable lid switch handling - https://codeberg.org/elloskelling/linux-gpd-pocket-4
  services = {
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
    thermald.enable = true;
  };

  environment.systemPackages = with pkgs; [
    acpi
    intel-gpu-tools
    lm_sensors
    powertop
    s-tui
    stress
  ];
}
