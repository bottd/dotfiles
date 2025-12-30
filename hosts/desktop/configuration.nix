{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../system/common/linux
  ];

  # Desktop-only: VR and game streaming
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    moonlight
  ];
}
