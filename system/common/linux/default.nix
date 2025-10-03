{ pkgs, ... }:
{
  imports = [
    ./boot.nix
    ./oom-management.nix
  ];

  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    podman-desktop
  ];
}
