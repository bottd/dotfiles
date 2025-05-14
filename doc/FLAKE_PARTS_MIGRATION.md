# Plan for Migration to Flake-Parts

## Background

The refactoring has successfully addressed path resolution issues and created a modular structure for both system and home-manager configurations. The flake now passes `nix flake check` and has working path resolution. The next step is to migrate from the current monolithic flake.nix to a flake-parts based structure for better maintainability and organization.

## Current Status

- ✅ Path resolution issues fixed
- ✅ Modular structure implemented
- ✅ Flake check passing
- ✅ Initial flake-parts integration completed
- ✅ All hosts configured in flake-parts (desktop, pocket, macbook)
- ✅ Required inputs added (nix-darwin, mac-app-util)
- ⏳ Future: Extract configurations into separate module files

## Current Structure

The flake.nix now has a cleaner organization using flake-parts:

1. **Common Module Arguments**
   ```nix
   _module.args = {
     # Helper function to create paths object for system configurations
     mkPaths = {
       root = ./.;
       system = ./system;
       systemModules = ./system/modules;
       # ... other paths
     };
   };
   ```

2. **Per-System Configuration**
   ```nix
   perSystem = { config, self', inputs', pkgs, system, ... }: {
     formatter = treefmt-nix.lib.mkWrapper ...
     devShells.default = pkgs.mkShell { ... };
   };
   ```

3. **System Configurations**
   ```nix
   flake = let
     paths = { ... };
   in {
     # NixOS configurations
     nixosConfigurations = {
       desktop = nixpkgs.lib.nixosSystem { ... };
       pocket = nixpkgs.lib.nixosSystem { ... };
     };

     # Darwin configurations
     darwinConfigurations = {
       macbook = nix-darwin.lib.darwinSystem { ... };
     };
   };
   ```

This structure provides several benefits:
- Clearly organized sections with proper documentation
- Consistent path handling using a single paths object
- Simplified specialArgs using the inherit keyword
- Proper separation between dev tools and system configurations

## Migration Plan

### Phase 1: Prepare for Migration ✅

1. **Create a feature-branch for the migration** ✅
   - Working on refactor branch
   - This allows for iterative development and testing

2. **Add flake-parts to inputs** ✅
   - Added flake-parts to inputs section
   - Configured to follow nixpkgs

### Phase 2: Implement Basic Flake-Parts Structure ✅

1. **Convert to flake-parts basic structure** ✅
   - Replaced the outputs function with `flake-parts.lib.mkFlake`
   - Moved formatter and devShell into the perSystem function
   - Set up systems list for "x86_64-linux" and "aarch64-darwin"

2. **Implement minimal working example** ✅
   - Started with treefmt and devShell in perSystem
   - Added nixosConfigurations in the flake attribute
   - Confirmed that `nix flake check` succeeds

### Phase 3: Migrate NixOS Configurations ✅

1. **Configure NixOS hosts** ✅
   - Configure desktop host in flake attribute
   - Configure pocket host in flake attribute
   - Test that both hosts build correctly

2. **Configure Darwin host** ✅
   - Add nix-darwin to inputs
   - Configure macbook host in darwinConfigurations attribute
   - Add required mac-app-util dependency
   - Test that macbook builds correctly

3. **Verify all hosts** ✅
   - Run flake check with all hosts
   - Fix any conflicts or issues discovered
   - Ensure consistent path handling for all hosts

### Phase 4: Extract reusable components ⏳

1. **Move common configurations to separate modules** ⏳
   - Create separate modules in nix/modules directory
   - Extract shared configuration patterns into modules
   - Organize modules by functionality and platform

2. **Improve specialArgs handling** ⏳
   - Streamline the passing of paths and other specialArgs
   - Use flake-parts supported mechanisms for handling paths
   - Create helper functions for common configurations

### Phase 5: Add Additional Features ⏳

1. **Add CI integration** ⏳
   - Set up github:hercules-ci/flake-modules-core for GitHub Actions
   - Configure basic checks (build, format)
   - Ensure all hosts are tested in CI

2. **Add deployment support** ⏳
   - Consider adding deploy-rs or similar deployment tools
   - Configure for supported hosts
   - Create deployment workflows

3. **Add documentation generator** ⏳
   - Set up a documentation generator for the flake
   - Document module interfaces and usage
   - Provide examples for common configurations

## Sample Structure

```nix
{
  description = "Drake Flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    
    # Other inputs remain unchanged
  };
  
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Import flake-parts modules
        inputs.treefmt-nix.flakeModule
        
        # Local modules
        ./nix/modules/nixos.nix
        ./nix/modules/home-manager.nix
        ./nix/modules/darwin.nix
      ];
      
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Formatter configuration
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
            stylua.enable = true;
            shfmt.enable = true;
            beautysh.enable = true;
            deadnix.enable = true;
            taplo.enable = true;
          };
        };
        
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            config.treefmt.build.wrapper
          ];
          
          shellHook = ''
            echo "🚀 Welcome to Drake's dotfiles dev shell"
            echo "Use 'treefmt' to format the code"
          '';
        };
      };
      
      # Flake outputs shared across systems
      flake = {
        # These will be defined by the imported modules
        # nixosConfigurations, darwinConfigurations, homeConfigurations
      };
    };
}
```

## Current Progress

The migration to flake-parts has been successful:

1. ✅ **Added flake-parts to inputs**: Flake-parts is properly configured
2. ✅ **Basic structure conversion**: The flake now uses the flake-parts format
3. ✅ **Working perSystem configuration**: Formatter and development shell work through flake-parts
4. ✅ **All hosts configured**: Desktop, pocket, and macbook hosts configured in flake-parts
5. ✅ **Required inputs added**: nix-darwin and mac-app-util added for macbook support
6. ✅ **Passing flake checks**: The flake successfully passes `nix flake check` for all hosts
7. ✅ **Legacy files removed**: Old nixOS and darwin directories removed
8. ✅ **Improved structure**: Organized flake.nix into clear sections
9. ✅ **Simplified path handling**: Using consistent paths object across all configurations

## Remaining Tasks

To further enhance the flake organization:

1. **Apply modular approach**: When ready to commit changes, move configurations to separate module files
2. **Add system-level abstractions**: Create helper functions for common configuration patterns
3. **Implement host profiles**: Create reusable profiles for different host types
4. **Add automated testing**: Set up testing for all configurations
5. **Document the new structure**: Update README.md with the new organization

The current state provides a clean, working implementation that leverages flake-parts for better organization while maintaining compatibility with the existing system. It also sets a solid foundation for future improvements when you're ready to commit the changes to git.