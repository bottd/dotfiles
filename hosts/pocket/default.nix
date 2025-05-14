{
  inputs,
  host,
  username,
  paths,
  lib,
  config,
  ...
}: {
  imports = [
    # Local hardware and host-specific configuration
    ./configuration.nix

    # Base system configuration
    (paths.system + "/base")
    (paths.system + "/common/linux")
    (paths.system + "/users")

    # Home manager configuration is handled in flake.nix
  ];
}
