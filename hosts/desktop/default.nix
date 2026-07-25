{ pkgs, ... }:
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
