{ pkgs, ... }:
{
  boot = {
    kernelParams = [
      # General power saving
      "ahci.mobile_lpm_policy=3"
      "pcie_aspm=force"
    ];
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Keep battery work within the low-power firmware envelope to limit short
  # heat spikes and the fan ramping they cause.
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_BOOST_ON_BAT = 0;
    PLATFORM_PROFILE_ON_BAT = "low-power";
  };

  # The Pocket 4 uses the DMI-bound gpd_fan driver, not gpd-pocket-fan. Stop
  # the fan during idle, then ramp to full speed before sustained high heat.
  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=5
      DEVPATH=hwmon6=devices/platform/gpd_fan hwmon5=devices/pci0000:00/0000:00:18.3
      DEVNAME=hwmon6=gpdfan hwmon5=k10temp
      FCTEMPS=hwmon6/pwm1=hwmon5/temp1_input
      FCFANS=hwmon6/pwm1=hwmon6/fan1_input
      MINTEMP=hwmon6/pwm1=52
      MAXTEMP=hwmon6/pwm1=85
      MINSTART=hwmon6/pwm1=40
      MINSTOP=hwmon6/pwm1=15
      MINPWM=hwmon6/pwm1=0
      MAXPWM=hwmon6/pwm1=255
    '';
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
  ];
}
