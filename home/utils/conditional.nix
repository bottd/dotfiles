# Utility module for conditional module loading in home-manager
{lib, ...}: rec {
  # Function to conditionally import a module based on a condition
  # Usage: conditional.import condition path
  import = condition: path:
    if condition
    then path
    else {};

  # Function to import a module only if a feature is enabled
  # Usage: conditional.withFeature config.feature.enable path
  withFeature = flag: path:
    import flag path;

  # Function to import a module only for a specific system
  # Usage: conditional.onlyOn "x86_64-linux" path
  onlyOn = system: path: currentSystem:
    import (currentSystem == system) path;

  # Function to import a module only for a specific host
  # Usage: conditional.onlyForHost "desktop" path
  onlyForHost = targetHost: path: currentHost:
    import (currentHost == targetHost) path;

  # Function to import a module only for NixOS
  # Usage: conditional.onlyNixOS path
  onlyNixOS = path: system:
    import (lib.strings.hasSuffix "linux" system) path;

  # Function to import a module only for Darwin
  # Usage: conditional.onlyDarwin path
  onlyDarwin = path: system:
    import (lib.strings.hasSuffix "darwin" system) path;

  # Function to merge several conditional modules
  # Usage: conditional.merge [module1 module2 module3]
  merge = modules:
    lib.fold lib.recursiveUpdate {} (lib.filter (m: m != {}) modules);
}
