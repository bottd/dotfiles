# Refactoring Status and Recommendations

## Current Status

1. ✅ **Flake-parts Integration**
   - ✅ Basic flake-parts structure implemented
   - ✅ Working flake check with minimal modifications
   - ✅ Dev shell added with flake check passing

2. ✅ **New Directory Structure**
   - ✅ Created `system/modules` with common settings
   - ✅ Created `system/hosts` for host-specific configs
   - ✅ Organized home-manager modules by platform
   - ✅ Created cross-platform module structure with platform detection

3. ❌ **Path Resolution Challenges**
   - ❌ Attempted multiple approaches to resolve path issues
   - ❌ None have fully worked without compatibility issues
   - ✅ Developed migration strategy (see MIGRATION.md)

## Path Resolution Challenges

When Nix evaluates files in the store, paths are processed differently than when working with local files:

1. **Main Issue**: Paths like `../../system/modules` don't resolve correctly in the Nix store
2. **Root Cause**: Files are copied to store locations like `/nix/store/hash-name/` where relative paths don't match

Solutions attempted:

1. **String interpolation with self.outPath**:
   ```nix
   "${inputs.self.outPath}/path/to/file"
   ```

2. **Using builtins.path for references**:
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
   imports = [ inputs.self.nixosModules.myModule ];
   ```

4. **Direct imports using inputs.self**:
   ```nix
   imports = [ (inputs.self + "/path/to/module") ];
   ```

None of these approaches resolved the issues completely. The recommended path forward is outlined in MIGRATION.md.

## Migration Strategy

The repository now contains both:

1. **Original structure (working)**:
   - `./darwin/` - For macOS configurations
   - `./nixOS/` - For NixOS configurations
   - `./home/` - For Home Manager configurations

2. **New structure (ready for migration)**:
   - `./system/modules/` - Common system modules
   - `./system/hosts/` - Host-specific configurations
   - `./home/common/` - Common home-manager modules
   - `./home/linux/` - Linux-specific home-manager modules
   - `./home/darwin/` - macOS-specific home-manager modules
   - `./home/hosts/` - Host-specific home-manager configurations

A detailed migration plan is available in MIGRATION.md, recommending a staged approach:

1. Stage 1: Direct module content duplication using wrapper modules
2. Stage 2: Integrate flake-utils-plus for better path handling
3. Stage 3: Consider two-stage evaluation approach if needed

## Next Steps

1. **Implement Stage 1 Migration**:
   - Start with one host (desktop)
   - Create wrapper modules in the original structure
   - Test thoroughly before proceeding to other hosts

2. **Explore flake-utils-plus**:
   - Research how it handles path resolution
   - Plan integration in medium term

3. **Switch from alejandra to treefmt**:
   - Install and configure treefmt for formatting
   - Set up treefmt with formatters for Nix and other languages
   - Update formatter hooks and CI checks to use treefmt

4. **Update Documentation**:
   - Keep track of migration progress
   - Document any additional findings

## Conclusion

The refactoring has made significant progress with the creation of a new, more modular directory structure. The path resolution issues present a challenge, but a clear migration strategy has been developed to address them. The goal remains to create a more maintainable and modular configuration while ensuring a smooth transition.