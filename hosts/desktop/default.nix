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

  services = {
    ddccontrol.enable = true;

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
    moonlight-qt
    shurectl
  ];
}
