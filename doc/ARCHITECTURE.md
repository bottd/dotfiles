# NixOS Dotfiles Architecture Documentation

## System Architecture Overview

```
┌─────────────────────────────────────────┐
│                flake.nix                │
│                                         │
│  ┌───────────────┐    ┌───────────────┐ │
│  │ NixOS Systems │    │Darwin Systems │ │
│  └───────┬───────┘    └───────┬───────┘ │
└──────────┼──────────────────┼───────────┘
           │                  │
           ▼                  ▼
┌──────────────────┐ ┌──────────────────┐
│  Host Configs    │ │  Host Configs    │
│  ┌────────────┐  │ │  ┌────────────┐  │
│  │ Overrides  │  │ │  │ Overrides  │  │
│  └────────────┘  │ │  └────────────┘  │
└────────┬─────────┘ └─────────┬────────┘
         │                     │
         ▼                     ▼
┌──────────────────┐ ┌──────────────────┐
│ System Modules   │ │ System Modules   │
└────────┬─────────┘ └─────────┬────────┘
         │                     │
         ▼                     ▼
┌──────────────────┐ ┌──────────────────┐
│ Home Modules     │ │ Home Modules     │
└──────────────────┘ └──────────────────┘
```

## Module System Design

```
┌────────────────────────────────────────┐
│           Configuration System         │
│                                        │
│  ┌────────────┐       ┌────────────┐   │
│  │  Defaults  │──────▶│  Overrides │   │
│  └────────────┘       └────────────┘   │
│         │                   │          │
│         └───────┬───────────┘          │
│                 │                      │
│                 ▼                      │
│         ┌────────────────┐             │
│         │  Final Config  │             │
│         └────────────────┘             │
└────────────────────────────────────────┘
```

## Directory Structure

```
.
├── flake.nix                # Main entry point
├── home.nix                 # Home-manager configuration
├── hosts.nix                # Host registry
├── system/                  # System configurations
│   ├── hosts/               # Host-specific configurations
│   │   ├── desktop/         # Desktop host
│   │   │   ├── configuration.nix  # Host-specific settings
│   │   │   ├── default.nix        # Host entry point
│   │   │   └── overrides.nix      # Config overrides
│   │   ├── macbook/         # MacBook host
│   │   └── pocket/          # Pocket host
│   └── modules/             # Shared system modules
│       ├── base/            # Base system settings
│       ├── common/          # Common settings (cross-platform)
│       │   ├── darwin/      # Darwin-specific settings
│       │   └── linux/       # Linux-specific settings
│       ├── config/          # Configuration modules
│       │   ├── default.nix  # Core configuration system
│       │   ├── desktop.nix  # Desktop environment config
│       │   ├── hardware.nix # Hardware configuration
│       │   ├── networking.nix # Networking configuration
│       │   └── security.nix # Security configuration
│       ├── profiles/        # System profiles
│       │   ├── darwin.nix   # Darwin profile
│       │   └── desktop-linux.nix # Desktop Linux profile
│       └── utils/           # Utilities
│           ├── conditional.nix # Conditional module loading
│           └── module-system.nix # Module system utilities
├── home/                    # Home-manager configurations
│   ├── common/              # Common home-manager modules
│   ├── darwin/              # Darwin-specific home modules
│   ├── features/            # Home features system
│   ├── linux/               # Linux-specific home modules
│   ├── profiles/            # Home profiles
│   │   ├── darwin.nix       # Darwin home profile
│   │   └── linux-desktop.nix # Linux desktop profile
│   └── utils/               # Home utilities
│       └── conditional.nix  # Conditional module loading
└── util/                    # Misc utilities
    └── createSymlink.nix    # Symlink creation utility
```

## Key Concepts

### 1. Flake Structure

The configuration is organized around a flake-based architecture that uses the following components:

- **flake.nix**: Main entry point that defines inputs, outputs, and helper functions
- **Module System**: A hierarchical system of modules for code organization
- **Configuration System**: A system for setting defaults and overrides
- **Conditional Loading**: A mechanism for loading modules conditionally

### 2. Helper Functions

The flake provides several helper functions to simplify configuration:

- **mkNixosSystem**: Creates standardized NixOS configurations
- **mkDarwinSystem**: Creates standardized Darwin configurations
- **mkHomeConfig**: Creates standardized home-manager configurations

Example usage:

```nix
# Create a NixOS system
nixosConfigurations.desktop = mkNixosSystem {
  host = "desktop";
  username = "drakeb";
};

# Create a Darwin system
darwinConfigurations.macbook = mkDarwinSystem {
  host = "macbook";
  username = "drakebott";
};
```

### 3. Configuration System

The configuration system provides a structured way to define and override configuration settings:

```nix
# Default configuration
sysConfig.hardware.defaults = {
  cpuType = "unknown";
  gpuType = "unknown";
  bluetooth = false;
};

# Override configuration for a specific host
sysConfig.hardware.overrides = {
  cpuType = "amd";
  gpuType = "nvidia";
  bluetooth = true;
};
```

The configuration system automatically merges defaults and overrides to produce the final configuration.

### 4. Conditional Module Loading

The conditional module loading system allows modules to be loaded based on conditions:

```nix
# Load a module only if a feature is enabled
conditional.withFeature config.features.desktop.hyprland
  (paths.systemModules + "/hyprland")
  
# Load a module only for a specific system
conditional.onlyOn "x86_64-linux" 
  (paths.systemModules + "/wayland") config.nixpkgs.system
  
# Load a module only for a specific host
conditional.onlyForHost "desktop" 
  (paths.systemModules + "/oom-protection") host
```

## Adding a New Host

### Step 1: Create the host directory structure

```bash
mkdir -p system/hosts/newhost
touch system/hosts/newhost/configuration.nix
touch system/hosts/newhost/default.nix
touch system/hosts/newhost/overrides.nix
```

### Step 2: Define the host configuration

```nix
# system/hosts/newhost/default.nix
{
  inputs,
  host,
  username,
  paths,
  lib,
  config,
  ...
}: {
  imports = [
    # Local hardware and host-specific configuration
    ./configuration.nix
    ./overrides.nix
    
    # Base system configuration
    (paths.systemModules + "/base")
    (paths.systemModules + "/common/linux")  # or common/darwin
    (paths.systemModules + "/users")
    (paths.systemModules + "/auto-hostname")
    (paths.systemModules + "/bootloader")
  ];
}
```

### Step 3: Define the host-specific configuration

```nix
# system/hosts/newhost/configuration.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix  # Generated with nixos-generate-config
  ];

  # Any host-specific settings
  
  system.stateVersion = "24.11";
}
```

### Step 4: Define configuration overrides

```nix
# system/hosts/newhost/overrides.nix
{ config, lib, pkgs, ... }: {
  # Override default hardware configuration
  sysConfig.hardware.overrides = {
    cpuType = "intel";
    gpuType = "intel";
    bluetooth = true;
    printing = false;
    sound = true;
  };
  
  # Override default desktop configuration
  sysConfig.desktop.overrides = {
    enable = true;
    useWayland = true;
    useHyprland = true;
  };
}
```

### Step 5: Add the host to flake.nix

```nix
# flake.nix
nixosConfigurations = {
  # Existing hosts...
  
  # New host
  newhost = mkNixosSystem {
    host = "newhost";
    username = "drakeb";
  };
};
```

## Adding a New Module

### Step 1: Create the module file

```nix
# system/modules/my-module/default.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Module definition here
  
  # Example: add a package
  environment.systemPackages = with pkgs; [
    mypackage
  ];
  
  # Example: enable a service
  services.myservice.enable = true;
}
```

### Step 2: Add the module to system/modules/default.nix

```nix
# system/modules/default.nix
imports = [
  # ... existing imports ...
  ./my-module
];
```

### Step 3: Use the module in a host configuration

```nix
# system/hosts/myhost/default.nix
imports = [
  # ... other imports ...
  (paths.systemModules + "/my-module")
];
```

### Step 4 (Optional): Add conditional loading

```nix
# system/hosts/myhost/default.nix
imports = let
  conditional = import (paths.systemModules + "/utils/conditional.nix") { inherit lib; };
in [
  # ... other imports ...
  (conditional.withFeature config.some.condition
    (paths.systemModules + "/my-module"))
];
```

## Module Override Examples

### Example 1: Override hardware configuration

```nix
sysConfig.hardware.overrides = {
  cpuType = "amd";
  gpuType = "nvidia";
  bluetooth = true;
  printing = true;
  sound = true;
  virtualization = true;
};
```

### Example 2: Override desktop environment

```nix
sysConfig.desktop.overrides = {
  enable = true;
  useWayland = true;
  useHyprland = true;
  useGnome = false;
  theme = {
    name = "catppuccin-macchiato";
    dark = true;
    accent = "mauve";
  };
};
```

### Example 3: Override development environment

```nix
sysConfig.development.overrides = {
  enable = true;
  languages = {
    python = true;
    rust = true;
    go = false;
    node = true;
  };
  tools = {
    vscode = true;
    neovim = true;
    docker = true;
  };
};
```

## Conditional Loading Examples

### Example 1: Load module based on feature flag

```nix
# Load wayland only if desktop.useWayland is true
(conditional.withFeature config.sysConfig.desktop.defaults.useWayland
  (paths.systemModules + "/wayland"))
```

### Example 2: Load different modules based on system type

```nix
# Load different modules for different systems
(if pkgs.stdenv.hostPlatform.isLinux then
  [
    (paths.systemModules + "/linux-specific-module")
  ]
else if pkgs.stdenv.hostPlatform.isDarwin then
  [
    (paths.systemModules + "/darwin-specific-module")
  ]
else [])
```

### Example 3: Load module only for specific CPU types

```nix
# Load module only for AMD CPUs
(conditional.import (config.sysConfig.hardware.defaults.cpuType == "amd")
  (paths.systemModules + "/amd-specific"))
```

## Best Practices

1. **Use the Configuration System**: Prefer using the configuration system with defaults and overrides for settings
2. **Keep Modules Focused**: Each module should have a single responsibility
3. **Conditional Loading**: Use the conditional loading system for optional modules
4. **Host-Specific Overrides**: Put host-specific settings in the overrides.nix file
5. **Common Configuration**: Put shared settings in the appropriate common modules
6. **Path Consistency**: Always use the paths object for file references
7. **Profiles for Common Patterns**: Create profiles for common combinations of modules