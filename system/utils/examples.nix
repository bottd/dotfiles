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
    (paths.system + "/base")

    # Conditional module loading based on features
    (conditional.withFeature config.features.desktop.hyprland
      (paths.system + "/hyprland"))

    (conditional.withFeature config.features.hardware.nvidia
      (paths.system + "/nvidia"))

    # Load modules only for specific systems
    (conditional.onlyNixOS (paths.system + "/wayland") config.nixpkgs.system)

    # Load modules only for specific hosts
    (conditional.onlyForHost "desktop"
      (paths.system + "/oom-protection")
      host)

    # Merge several conditional modules
    (conditional.merge [
      (conditional.withFeature config.features.security.yubikey
        (paths.system + "/yubikey"))
      (conditional.withFeature config.features.security.ssh
        (paths.system + "/ssh"))
    ])
  ];
}
