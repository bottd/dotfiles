{ pkgs, ... }:
let
  shurectl = pkgs.callPackage ./shurectl.nix { };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../system/common/linux
    ../../system/nixOS/jellyfin.nix
  ];

  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  # Not services.ddccontrol: its ddcci kernel module can't auto-probe displays
  # since Linux 6.8, so it binds nothing.
  hardware.i2c.enable = true;

  services = {
    sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = false;
      openFirewall = true;
    };

    # The package ships the udev rule that uaccess-tags the MV7+'s hidraw node,
    # so shurectl reaches the mic's onboard DSP without root.
    udev.packages = [ shurectl ];
  };

  environment.systemPackages = with pkgs; [
    # For probing DDC by hand. The `brightness` script gets its own copy from
    # scripts/brightness.nix and does not depend on this one.
    ddcutil
    moonlight-qt
    shurectl
  ];
}
