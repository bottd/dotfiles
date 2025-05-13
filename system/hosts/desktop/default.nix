{
  inputs,
  host,
  username,
  paths,
  ...
}: {
  imports = [
    # Local configuration using relative paths
    ./configuration.nix

    # Import only the specific modules we need
    (paths.systemModules + "/base")

    # Linux-specific common modules
    (paths.systemModules + "/common/linux")

    # User management
    (paths.systemModules + "/users")

    # Hyprland window manager - temporarily commented out until module can be properly added
    # (paths.systemModules + "/hyprland")

    # Home manager configuration is handled in flake.nix
  ];
}
