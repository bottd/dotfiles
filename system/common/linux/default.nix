{ ... }:
{
  imports = [
    ./boot.nix
    ./oom-management.nix
  ];

  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;
}
