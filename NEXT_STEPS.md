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

## Next Steps

1. **Test Path Resolution Approaches**
   - Run `nix flake check` to validate which approach works
   - If none work, consider adding flake-utils-plus to help
   - Test with a specific configuration (pocket host)

2. **Implement the Working Approach**
   - Once a working approach is found, apply it consistently
   - Update all host configurations to use the same pattern

3. **Migrate Remaining Hosts**
   - After path resolution is stable, implement all hosts
   - Create a systematic approach to migration

4. **Formatter Improvement**
   - Replace alejandra with treefmt for better formatting control
   - Configure treefmt with formatters for Nix and other languages
   - Integrate treefmt into the development shell

## Implementation Notes

When evaluating which approach works best:

1. **Check Error Messages**
   Look for specific path resolution errors to understand what's failing:
   - "path '/nix/store/hash-source/path' does not exist"
   - "cannot coerce a path to a string"
   - "file not found in input"

2. **Debugging Techniques**
   - Use `builtins.trace` to see what paths are being resolved
   - Break down complex imports into smaller parts
   - Use flake's native mechanisms for exposing modules

3. **Consider Alternative Libraries**
   - flake-utils-plus: Has better path handling
   - nix-flake-common: Provides standardized helpers
   - flake-compat: For backwards compatibility