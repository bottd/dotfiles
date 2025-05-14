{
  inputs,
  host,
  username,
  lib,
  ...
}: {
  imports = [
    # Local hardware and host-specific configuration
    ./configuration.nix

    # Base system configuration
    ../../system/base
    ../../system/common/linux
    ../../system/users

    # Home manager configuration is handled in flake.nix
  ];
}
