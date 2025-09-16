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
    logind = {
      lidSwitch = "ignore";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "ignore";
    };
    thermald.enable = true;
  };

  # TLP configuration - https://wiki.nixos.org/wiki/Laptop
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #     CPU_MIN_PERF_ON_AC = 0;
  #     CPU_MAX_PERF_ON_AC = 100;
  #     CPU_MIN_PERF_ON_BAT = 0;
  #     CPU_MAX_PERF_ON_BAT = 60; # Keep 60% performance on battery
  #
  #     INTEL_GPU_MIN_FREQ_ON_AC = 100;
  #     INTEL_GPU_MIN_FREQ_ON_BAT = 100;
  #     INTEL_GPU_MAX_FREQ_ON_AC = 1300;
  #     INTEL_GPU_MAX_FREQ_ON_BAT = 800;
  #
  #     # Battery charge thresholds for longevity
  #     START_CHARGE_THRESH_BAT0 = 30;
  #     STOP_CHARGE_THRESH_BAT0 = 80;
  #
  #     DISK_DEVICES = "mmcblk0 nvme0n1";
  #
  #     RUNTIME_PM_ON_AC = "on";
  #     RUNTIME_PM_ON_BAT = "auto";
  #
  #     WIFI_PWR_ON_AC = "off";
  #     WIFI_PWR_ON_BAT = "on";
  #
  #     USB_AUTOSUSPEND = 1;
  #     USB_EXCLUDE_BTUSB = 1;
  #   };
  # };
  #
  environment.systemPackages = with pkgs; [
    powertop
    # tlp
    acpi
    lm_sensors
    intel-gpu-tools
    s-tui
    stress
  ];
}
