# Examples module showing how to use the conditional module loading
{
  config,
  lib,
  system,
  host,
  paths,
  ...
}: let
  # Import the conditional module
  conditional = import ./conditional.nix {inherit lib;};
in {
  # Use a module only if a feature is enabled
  imports = [
    # Basic modules that are always loaded
    (paths.systemModules + "/base")

    # Conditional module loading based on features
    (conditional.withFeature config.features.desktop.hyprland
      (paths.systemModules + "/hyprland"))

    (conditional.withFeature config.features.hardware.nvidia
      (paths.systemModules + "/nvidia"))

    # Load modules only for specific systems
    (conditional.onlyNixOS (paths.systemModules + "/wayland") config.nixpkgs.system)

    # Load modules only for specific hosts
    (conditional.onlyForHost "desktop"
      (paths.systemModules + "/oom-protection")
      host)

    # Merge several conditional modules
    (conditional.merge [
      (conditional.withFeature config.features.security.yubikey
        (paths.systemModules + "/yubikey"))
      (conditional.withFeature config.features.security.ssh
        (paths.systemModules + "/ssh"))
    ])
  ];
}
