# Darwin profile combining common macOS modules
{
  paths,
  inputs,
  ...
}: {
  imports = [
    # Basic system
    (paths.systemModules + "/base")
    (paths.systemModules + "/common/darwin")
    (paths.systemModules + "/darwin-base")
    (paths.systemModules + "/users")
    (paths.systemModules + "/auto-hostname")

    # Additional modules
    (paths.systemModules + "/fonts")
    (paths.systemModules + "/dev-tools")

    # macOS-specific utilities
    inputs.mac-app-util.darwinModules.default
  ];

  # Set default darwin settings
  environment.systemPackages = with inputs.nixpkgs.legacyPackages.aarch64-darwin; [
    # macOS helpers
    m-cli
    dockutil

    # These are generally useful on macOS
    coreutils
    findutils
  ];
}
