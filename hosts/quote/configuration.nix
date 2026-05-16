{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../system/common/linux
  ];

  networking.hostName = "quote";

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    ghostty
    temurin-bin-21
    git
  ];

  # quote shares the desktop host's home; pin UID so workspace files keep ownership
  users.users.drakeb.uid = 1000;
}
