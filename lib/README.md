# Library Functions (Deprecated)

This directory contains helper functions that were used in the previous version of the configuration. These functions are now deprecated and have been replaced by the helper functions in the `flake.nix` file.

## Migration Path

The functions in this directory (`mkSystem.nix` and `mkHome.nix`) have been refactored into:

1. `mkNixosSystem` - For creating NixOS configurations
2. `mkDarwinSystem` - For creating Darwin configurations  
3. `mkHomeConfig` - For creating home-manager configurations

These new functions are now defined in the `_module.args` section of `flake.nix` and use the consistent `paths` object for better path handling.

## Key Differences

The new approach:

1. Uses a consistent `paths` object for all file references
2. Integrates with flake-parts for better modularity
3. Separates NixOS and Darwin configuration logic
4. Has cleaner home-manager integration
5. Is declared directly where it's used, rather than in separate files

## Future Plans

These files will be maintained for reference until the refactoring is complete, then they will be removed.