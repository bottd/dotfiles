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
    # Local configuration using relative paths
    ./configuration.nix

    # Base system configuration
    (paths.systemModules + "/base")
    (paths.systemModules + "/common/darwin")
    (paths.systemModules + "/users")

    # macOS-specific utilities
    inputs.mac-app-util.darwinModules.default

    # Set home directory for macOS
    {
      users.users.${username}.home = "/Users/${username}";
    }

    # Home manager configuration is handled in flake.nix
  ];
}
