{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

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
}
