# Usage Examples for the Refactored Nix Configuration

This document provides examples of how to use the refactored configuration for common tasks.

## Adding a New Host

Adding a new host is now much simpler:

### 1. Create the host directory structure

```bash
mkdir -p system/hosts/newhost
touch system/hosts/newhost/configuration.nix
touch system/hosts/newhost/default.nix
touch system/hosts/newhost/features.nix
# If it's a NixOS system
touch system/hosts/newhost/hardware-configuration.nix
```

### 2. Set up the host configuration

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
  imports = let
    # Import the conditional module
    conditional = import (paths.systemModules + "/utils/conditional.nix") { inherit lib; };
  in [
    # Local hardware and host-specific configuration
    ./configuration.nix
    ./features.nix

    # Features system
    (paths.systemModules + "/features")
    
    # Base system configuration
    (paths.systemModules + "/base")
    (paths.systemModules + "/common/linux")  # or common/darwin
    (paths.systemModules + "/users")
    (paths.systemModules + "/auto-hostname")

    # Hardware-specific modules
    (paths.systemModules + "/bootloader")
    
    # Conditional modules based on features
    (conditional.withFeature config.features.desktop.enable
      (paths.systemModules + "/display-server"))
    (conditional.withFeature config.features.desktop.wayland
      (paths.systemModules + "/wayland"))
    (conditional.withFeature config.features.desktop.hyprland
      (paths.systemModules + "/hyprland"))

    # Additional modules
    (paths.systemModules + "/fonts")
    (paths.systemModules + "/dev-tools")
  ];
}
```

### 3. Configure features for the host

```nix
# system/hosts/newhost/features.nix
{
  config,
  lib,
  ...
}: {
  # Enable host-specific features
  features = {
    desktop = {
      enable = true;
      wayland = true;
      hyprland = true;
      gaming = false;
    };
    
    dev = {
      enable = true;
      python = true;
      rust = false;
      node = true;
      go = false;
    };
    
    hardware = {
      nvidia = false;
      intel = true;
      amd = false;
      bluetooth = true;
      printing = true;
      virtualisation = false;
    };
    
    security = {
      yubikey = true;
      ssh = true;
      firewall = true;
    };
  };
}
```

### 4. Add host-specific settings

```nix
# system/hosts/newhost/configuration.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Any host-specific settings can go here
  
  # Use this fixed version - do not change without reading docs
  system.stateVersion = "24.11";
}
```

### 5. Add the host to flake.nix

```nix
# In flake.nix, add to the nixosConfigurations or darwinConfigurations section
nixosConfigurations = {
  # ... existing hosts ...
  
  # New host
  newhost = mkNixosSystem {
    host = "newhost";
    username = "drakeb";
  };
};
```

## Adding a New Module

### 1. Create a new module file

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

### 2. Add the module to system/modules/default.nix

```nix
# Add to the imports list in system/modules/default.nix
imports = [
  # ... existing modules ...
  ./my-module
];
```

### 3. Use the module conditionally

```nix
# In the host configuration, import it conditionally
imports = let
  conditional = import (paths.systemModules + "/utils/conditional.nix") { inherit lib; };
in [
  # ... other imports ...
  
  # Conditional import
  (conditional.withFeature config.features.some.feature
    (paths.systemModules + "/my-module"))
];
```

## Adding a New Feature Flag

### 1. Update the features module

```nix
# system/modules/features/default.nix
options.features = {
  # ... existing options ...
  
  # New feature category
  my-feature = {
    enable = lib.mkEnableOption "Enable my custom feature";
    option1 = lib.mkEnableOption "Option 1 for my feature";
    option2 = lib.mkEnableOption "Option 2 for my feature";
  };
};

# Default values
config = {
  # ... existing defaults ...
  
  # Defaults for new feature
  features.my-feature = {
    enable = false;
    option1 = false;
    option2 = false;
  };
};
```

### 2. Enable the feature in a host

```nix
# system/hosts/myhost/features.nix
features = {
  # ... existing features ...
  
  # Enable my feature
  my-feature = {
    enable = true;
    option1 = true;
    option2 = false;
  };
};
```

## Using Conditional Module Loading

### Basic Conditionals

```nix
# Load module only if a feature is enabled
(conditional.withFeature config.features.desktop.hyprland
  (paths.systemModules + "/hyprland"))
  
# Load module only for a specific host
(conditional.onlyForHost "desktop" 
  (paths.systemModules + "/oom-protection") host)
  
# Load module only for a specific system
(conditional.onlyOn "x86_64-linux" 
  (paths.systemModules + "/some-module") config.nixpkgs.system)
  
# Load module only for NixOS
(conditional.onlyNixOS 
  (paths.systemModules + "/wayland") config.nixpkgs.system)
  
# Load module only for Darwin
(conditional.onlyDarwin 
  (paths.systemModules + "/darwin-specific") config.nixpkgs.system)
```

### Combining Conditionals

```nix
# Merge several conditional modules
(conditional.merge [
  (conditional.withFeature config.features.security.yubikey 
    (paths.systemModules + "/yubikey"))
  (conditional.withFeature config.features.security.ssh
    (paths.systemModules + "/ssh"))
])

# Complex condition
(conditional.import 
  (config.features.desktop.enable && config.features.desktop.wayland) 
  (paths.systemModules + "/wayland"))
```

## Creating a New Profile

```nix
# system/modules/profiles/minimal.nix
{
  paths,
  lib,
  config,
  ...
}: let
  conditional = import (paths.systemModules + "/utils/conditional.nix") { inherit lib; };
in {
  imports = [
    # Base modules
    (paths.systemModules + "/base")
    (paths.systemModules + "/common/linux")
    (paths.systemModules + "/users")
    (paths.systemModules + "/auto-hostname")
    
    # Minimal set of modules
    (paths.systemModules + "/bootloader")
    
    # Conditional modules
    (conditional.withFeature config.features.dev.enable
      (paths.systemModules + "/dev-tools"))
  ];
  
  # Set default feature flags for this profile
  features = {
    desktop.enable = false;
    dev.enable = true;
  };
}
```