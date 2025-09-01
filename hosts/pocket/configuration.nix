{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    grim
    slurp
    mako
    helvum
    ghostty
  ];

  system.stateVersion = "25.05";
}
