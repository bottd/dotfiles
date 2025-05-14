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
    (paths.systemModules + "/base")
    (paths.systemModules + "/common/linux")
    (paths.systemModules + "/users")

    # Home manager configuration is handled in flake.nix
  ];
}
