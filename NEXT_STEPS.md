# Next Steps for Dotfiles Refactoring

## Current Status

1. **Flake-parts Integration**
   - ✅ Restructured flake.nix to use flake-parts
   - ✅ Improved organization and reduced boilerplate
   - ✅ Added development shell for working on the dotfiles

2. **Path Resolution Approaches (Multiple Attempts)**
   - ✅ Created centralized path registry in lib/default.nix
   - ✅ Tried multiple approaches to fix store path issues:
     1. Using self.outPath for explicit string paths
     2. Using builtins.path for path references
     3. Exposing modules through flake.nixosModules
     4. Direct imports using inputs.self
   - ⏳ Need to validate which approach works best

3. **Standardized Module System Design**
   - ✅ Created system/modules structure for shared functionality
   - ✅ Added common modules for both NixOS and Darwin
   - ✅ Implemented platform detection for conditional imports

4. **Host Configuration Templates**
   - ✅ Created directory structure and configuration files
   - ✅ Set up the template files for all hosts
   - ⏳ Need to validate that templates work with path resolution

## Path Resolution Issue

The key issue that needs to be resolved is how to handle paths when Nix evaluates the flake. When Nix copies files to the Nix store, relative paths like `../home.nix` break because the directory structure is different. 

We've tried several approaches:

1. **String interpolation with self.outPath**:
   ```nix
   "${inputs.self.outPath}/path/to/file"
   ```

2. **builtins.path for path references**:
   ```nix
   builtins.path {
     path = ../../path/to/file;
     name = "file-name";
   }
   ```

3. **Exposing modules through flake outputs**:
   ```nix
   # In flake.nix
   nixosModules.myModule = ./path/to/module;
   
   # In configuration
   imports = [
     inputs.self.nixosModules.myModule
   ];
   ```

4. **Direct inputs.self imports**:
   ```nix
   imports = [
     (inputs.self + "/path/to/module")
   ];
   ```

## Completed Tasks

1. ✅ **Path Resolution Solved**
   - ✅ Successfully passed paths object through specialArgs
   - ✅ Fixed store evaluation issues with direct paths
   - ✅ All hosts build correctly with the new approach

2. ✅ **Implemented the Working Approach**
   - ✅ Consistently using paths.* approach for module imports
   - ✅ All host configurations updated to use the same pattern
   - ✅ Flake check passing with the new structure

3. ✅ **Migrated All Hosts**
   - ✅ Desktop and pocket NixOS hosts migrated
   - ✅ Macbook Darwin host migrated
   - ✅ Iris standalone home-manager configuration migrated

4. ✅ **Formatter Improvement**
   - ✅ Replaced alejandra with treefmt for better formatting control
   - ✅ Configured treefmt with formatters for Nix, Lua, Shell, and TOML
   - ✅ Added treefmt to the development shell

## Completed Improvements

1. ✅ **Helper Functions for System Configuration**
   - ✅ Created `mkNixosSystem` for standardized NixOS configurations
   - ✅ Created `mkDarwinSystem` for standardized Darwin configurations
   - ✅ Created `mkHomeConfig` for standardized home-manager configurations
   - ✅ Simplified flake.nix using these helper functions
   - ✅ Consistent pattern for all system configurations

2. ✅ **Improved Path Handling**
   - ✅ Comprehensive paths object with all major directories
   - ✅ Consistent path reference style throughout configurations
   - ✅ Documentation of path handling approach

3. ✅ **Lib Directory Documentation**
   - ✅ Added README.md to explain legacy code
   - ✅ Documented the migration path from old to new approach
   - ✅ Marked deprecated code that will be removed later

## Completed Improvements

4. ✅ **Fixed Critical Build Issues**
   - ✅ Added proper bootloader configuration for all NixOS hosts
   - ✅ Fixed NixOS assertion failures for bootable systems
   - ✅ Successfully ran flake check on all configurations
   - ✅ Ensured consistent bootloader configuration across hosts

## Future Improvements

1. **Further Refactor Common Settings**
   - Further consolidate duplicated settings across hosts
   - Create more specialized modules for common functionality
   - Improve code reuse across platforms

2. **Enhance Development Experience**
   - Add more development tools to the dev shell
   - Consider integrated testing approach for configurations
   - Add pre-commit hooks for formatting and validation

3. **Documentation**
   - Create README with clear explanation of the structure
   - Document how to add new hosts using the new structure
   - Provide examples for common configuration patterns

4. **Remove Legacy Code**
   - Remove deprecated lib directory after confirming stability
   - Clean up any remaining duplicate code paths
   - Standardize on the new helper function approach

## Implementation Details

The most successful approach used for path resolution was:

1. **Define a comprehensive paths object**
   ```nix
   paths = {
     root = ./.;
     # System paths
     system = ./system;
     systemHosts = ./system/hosts;
     systemModules = ./system/modules;
     # Home-manager paths
     home = ./home;
     homeCommon = ./home/common;
     homeDarwin = ./home/darwin;
     homeLinux = ./home/linux;
     homeHosts = ./home/hosts;
     # Utility paths
     util = ./util;
     # Configuration for nixOS hosts
     nixOS = ./nixOS;
   };
   ```

2. **Use paths directly in imports**
   ```nix
   imports = [
     (paths.systemModules + "/base")
     (paths.systemModules + "/common/linux")
   ];
   ```

3. **Create helper functions for common configurations**
   ```nix
   # Create a NixOS configuration with standard settings
   mkNixosSystem = { host, username, system ? "x86_64-linux", extraModules ? [] }:
     nixpkgs.lib.nixosSystem {
       inherit system;
       specialArgs = {
         inherit inputs paths username;
         host = host;
       };
       modules = [
         (paths.systemHosts + "/${host}")
         home-manager.nixosModules.home-manager
         (mkHomeConfig {
           inherit username host;
           isLinux = true;
         })
       ] ++ extraModules;
     };
   ```

4. **Simplify configuration in flake.nix**
   ```nix
   # NixOS configurations
   nixosConfigurations = {
     # Desktop configuration
     desktop = mkNixosSystem {
       host = "desktop";
       username = "drakeb";
     };
   };
   ```

5. **Avoid circular dependencies**
   - Keep imports specific and direct
   - Avoid importing the entire modules directory
   - Import only what's needed for each configuration

This approach has proven to be the most reliable, as it avoids issues with store path resolution by providing explicit paths rather than relying on relative paths. The addition of helper functions further improves maintainability by standardizing the configuration pattern across all systems.