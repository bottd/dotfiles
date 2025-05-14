# Drake's NixOS, Darwin & Home Manager Flake

A comprehensive, cross-platform system configuration using Nix Flakes. This repository contains configurations for:

- NixOS (Linux) machines
- macOS machines via nix-darwin
- Home Manager configurations for both platforms

## Structure

The repository is organized in a clean, modular structure:

```
.
├── system/                  # System configurations (NixOS, Darwin)
│   ├── base/                # Base system settings
│   ├── common/              # Common modules for all platforms
│   │   ├── linux/           # Linux-specific common settings
│   │   └── darwin/          # Darwin-specific common settings
│   ├── darwin-base/         # Base settings for Darwin systems
│   ├── dev-tools/           # Development tools configuration
│   ├── display-server/      # Display server configuration
│   ├── features/            # Optional system features
│   ├── hyprland/            # Hyprland compositor configuration
│   ├── nixOS/               # NixOS-specific modules
│   │   └── hyprland/        # Hyprland configuration for NixOS
│   ├── users/               # User management
│   ├── utils/               # Utility functions for system configs
│   └── wayland/             # Wayland-specific configuration
│
├── home/                    # Home-manager configurations
│   ├── common/              # Common home-manager modules
│   │   ├── language/        # Programming language support
│   │   ├── neovim/          # Neovim configuration
│   │   ├── nushell/         # Nushell configuration
│   │   └── starship/        # Starship prompt configuration
│   ├── linux/               # Linux-specific home settings
│   │   └── hyprland/        # Hyprland desktop environment
│   ├── darwin/              # Darwin-specific home settings
│   │   ├── aerospace/       # Window manager for macOS
│   │   └── karabiner/       # Keyboard customization for macOS
│   └── opt/                 # Optional configurations
│
├── hosts/                   # Host-specific configurations
│   ├── desktop/             # Desktop PC configuration (NixOS)
│   ├── pocket/              # Portable PC configuration (NixOS)
│   ├── macbook/             # MacBook configuration (Darwin)
│   └── iris/                # Standalone home-manager configuration
│
├── lib/                     # Helper functions and modules
│   ├── createSymlink.nix    # Utility for creating symlinks to dotfiles
│   ├── mkHome.nix           # Function to create home-manager configurations
│   └── mkSystem.nix         # Function to create system configurations
│
├── flake.nix                # Main flake configuration with host definitions
└── home.nix                 # Common home-manager configuration
```

## Platforms Supported

- **NixOS**: Desktop and Pocket configurations
- **macOS (Darwin)**: Full system and standalone home-manager configurations

## Usage

### System Configuration

#### NixOS (Linux)
```bash
# Build and switch to the desktop configuration
sudo nixos-rebuild switch --flake .#nixosConfigurations.desktop

# OR for the pocket device
sudo nixos-rebuild switch --flake .#nixosConfigurations.pocket
```

#### macOS (via nix-darwin)
```bash
# Build and switch to the macbook configuration
darwin-rebuild switch --flake .#darwinConfigurations.macbook
```

### Home Manager Configuration (Standalone)

```bash
# For the iris configuration
home-manager switch --flake .#homeConfigurations.iris
```

## Features

- **Cross-platform**: Common configuration shared between Linux and macOS
- **Terminal**: nushell, zsh, starship prompt, ghostty terminal
- **Desktop**: Hyprland compositor on Linux, Aerospace window manager on macOS
- **Development**: Neovim with LSP, VSCode, language-specific tooling
- **Dotfiles**: Managed by Home Manager for consistent experience across machines

## Helper Functions

The lib directory includes several helper functions to make system configuration more maintainable:

- **mkSystem**: Creates standardized system configurations (NixOS or Darwin)
  ```nix
  desktop = lib.mkSystem {
    hostName = "desktop";
    system = "x86_64-linux";
    username = "drakeb";
    format = "nixos";
    extraModules = [
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            neorgWorkspace = "chalet";
            root = ./.;
          };
        };
      }
    ];
  };
  ```

- **mkHome**: Creates standardized standalone home-manager configurations
  ```nix
  iris = lib.mkHome {
    hostName = "iris";
    system = "aarch64-darwin";
    username = "drakebott";
    format = "home-manager";
  };
  ```

- **createSymlink**: Utility for creating symlinks to dotfiles
  ```nix
  source = config.lib.meta.createSymlink "home/common/neovim/lua";
  ```

## Key Components

- [NixOS](https://nixos.org/) - Linux distribution based on Nix package manager
- [Nix Flakes](https://nixos.wiki/wiki/Flakes) - Reproducible builds and deployments
- [Home Manager](https://github.com/nix-community/home-manager) - Dotfile management using Nix
- [nix-darwin](https://github.com/LnL7/nix-darwin) - macOS system configuration with Nix
- [Hyprland](https://hyprland.org/) - Tiling Wayland compositor for Linux
- [Aerospace](https://aerospace.docs.felixkratz.me/) - Window manager for macOS

## Requirements

- Nix package manager with flakes enabled
- For macOS: nix-darwin
- For dotfiles only: home-manager

## License

This configuration is shared as a reference. Feel free to use it as inspiration for your own setup.