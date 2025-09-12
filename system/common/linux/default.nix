{ ... }:
{
  imports = [
    ./boot.nix
    ./oom-management.nix
  ];

  networking.networkmanager.enable = true;
}
