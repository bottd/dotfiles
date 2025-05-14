# Migration to New Directory Structure

## Overview

This document outlines the plan for migrating from the current directory structure to the new modular organization. Due to Nix store path evaluation challenges, this is a non-trivial task that requires careful planning.

## Current Status

1. ✅ **New Directory Structure Created**:
   - System modules organized in `system/modules/`
   - Host-specific configurations in `system/hosts/`
   - Home manager modules organized by platform
   - Directory structure follows best practices

2. ✅ **Stage 1 Migration Implemented**:
   - ✅ Successfully migrated desktop host configuration using inline wrappers
   - ✅ Successfully migrated pocket host configuration using inline wrappers
   - ✅ Flake check passes with no path resolution issues
   - ⏳ Darwin and Home Manager configurations still using original structure

3. ⏳ **Next Hosts to Migrate**:
   - ✅ Desktop (NixOS) - migrated
   - ✅ Pocket (NixOS) - migrated
   - ⏳ Macbook (Darwin) - pending migration
   - ⏳ Iris (Home Manager) - pending migration

## Migration Tactics

After multiple attempts, we found the most effective approach:

### Inline Module Wrapper Approach

Instead of importing modules (which has path resolution issues), we include the module content directly in the flake:

```nix
# In flake.nix:
desktop = inputs.nixpkgs.lib.nixosSystem {
  modules = [
    # Basic configurations
    ./nixOS/desktop/configuration.nix
    
    # Base settings wrapper included directly
    ({ pkgs, lib, config, ... }: {
      # Basic nix settings
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        # ... rest of settings inline ...
      };
    })
    
    # More inline modules...
  ];
};
```

Pros:
- Works reliably with no path resolution issues
- All path references are direct and explicit
- Flake check passes successfully

Cons:
- Module content duplication
- Need to keep wrappers in sync with new structure

## Future Approaches to Consider

### Option 1: flake-utils-plus

Add flake-utils-plus as a dependency for better path handling.

### Option 2: Two-Stage Evaluation

Implement a two-stage evaluation approach for more complex path resolution.

## Recommended Next Steps

1. **Continue Stage 1 Migration**:
   - Apply the same inline wrapper approach to macbook host
   - Then migrate iris home-manager configuration
   - Test thoroughly between each migration

2. **Platform-Specific Considerations**:
   - For Darwin configurations, create appropriate Darwin-specific wrappers
   - For Home Manager, simplify wrappers to focus on home configuration

3. **Research flake-utils-plus**:
   - Understand how it handles path resolution
   - Plan for integration in medium term

## Conclusion

We've successfully implemented Stage 1 of the migration for both NixOS hosts (desktop and pocket). The inline wrapper approach provides a working solution while preserving the new module structure. This proves the viability of the migration strategy and provides a clear path for migrating the remaining hosts.