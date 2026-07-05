{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../system/common/linux
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # grim/slurp/mako now come from the niri modules (screenshots are built-in;
  # mako runs as a home-manager user service).
  environment.systemPackages = with pkgs; [
    crosspipe
    ghostty
  ];
}
