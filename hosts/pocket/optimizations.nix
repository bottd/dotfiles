{ pkgs, ... }:
{
  # Keep battery work within the low-power firmware envelope to limit short
  # heat spikes and the fan ramping they cause.
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_BOOST_ON_BAT = 0;
    PLATFORM_PROFILE_ON_BAT = "low-power";
  };

  # The Pocket 4 uses the DMI-bound gpd_fan driver, not gpd-pocket-fan. Stop
  # the fan during idle, then ramp to full speed before sustained high heat.
  #
  # hwmon numbers follow probe order and move between boots, and fancontrol
  # refuses to start once they do. udev links the two chips under stable
  # names instead, and tags them so fancontrol waits for both to exist.
  services.udev.extraRules = ''
    SUBSYSTEM=="hwmon", ATTR{name}=="gpdfan|k10temp", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/sys/subsystem/hwmon/devices/$attr{name}", RUN+="${pkgs.coreutils}/bin/mkdir -p /run/hwmon", RUN+="${pkgs.coreutils}/bin/ln -sfn /sys$devpath /run/hwmon/$attr{name}"
  '';

  # fancontrol has no hysteresis, so the curve follows Tctl, which jumps
  # 10-20 °C on short bursts. AVERAGE smooths it over 10 samples (20 s), so
  # bursts never move the fan and only sustained load does.
  #
  # The EC takes 1-244 and the driver scales 0-255 onto that, so MINSTOP=15
  # was ~6% duty. A fan stalled there reads 0 RPM, and fancontrol re-kicks
  # it every interval, so the fan pulses. 50/100 sit well clear of that. To
  # find the real stall point: write 1 to pwm1_enable, step pwm1 down, and
  # watch fan1_input in /run/hwmon/gpdfan.
  hardware.fancontrol = {
    enable = true;
    config =
      let
        pwm = "/run/hwmon/gpdfan/pwm1";
      in
      ''
        INTERVAL=2
        FCTEMPS=${pwm}=/run/hwmon/k10temp/temp1_input
        FCFANS=${pwm}=/run/hwmon/gpdfan/fan1_input
        AVERAGE=${pwm}=10
        MINTEMP=${pwm}=52
        MAXTEMP=${pwm}=85
        MINSTART=${pwm}=100
        MINSTOP=${pwm}=50
        MINPWM=${pwm}=0
        MAXPWM=${pwm}=255
      '';
  };

  systemd.services.fancontrol = rec {
    bindsTo = [
      "sys-subsystem-hwmon-devices-gpdfan.device"
      "sys-subsystem-hwmon-devices-k10temp.device"
    ];
    after = bindsTo;
    # On exit, fancontrol tries to restore the EC's mode but can't read pwm1
    # in auto mode, so it falls back to full speed. That happens on every
    # resume restart and at shutdown. Hand the fan back to the EC's own curve
    # instead.
    serviceConfig = {
      ExecStopPost = "-${pkgs.runtimeShell} -c 'echo 2 > /run/hwmon/gpdfan/pwm1_enable'";
      RestartSec = 5;
    };
  };

  environment.systemPackages = with pkgs; [
    acpi
    lm_sensors
  ];
}
