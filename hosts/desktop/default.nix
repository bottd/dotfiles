{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../system/common/linux
    ../../system/nixOS/jellyfin.nix
  ];

  services.ddccontrol.enable = true;

  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    moonlight
  ];
}
