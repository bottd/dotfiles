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
│   ├── modules/             # Shared system modules
│   │   ├── base/            # Base system settings
│   │   ├── common/          # Common modules for all platforms
│   │   │   ├── linux/       # Linux-specific common settings
│   │   │   └── darwin/      # Darwin-specific common settings
│   │   └── users/           # User management
│   └── hosts/               # Host-specific configurations
│       ├── desktop/         # Desktop PC configuration (NixOS)
│       ├── pocket/          # Portable PC configuration (NixOS)
│       └── macbook/         # MacBook configuration (Darwin)
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
│   └── hosts/               # Host-specific home-manager configurations
│       └── iris/            # Standalone home-manager configuration
│
├── flake.nix               # Main flake configuration with helper functions
├── home.nix                # Common home-manager configuration
├── hosts.nix               # Host definitions and metadata
├── lib/                    # Helper functions (deprecated, see flake.nix)
└── util/                   # Helper utilities
```

See REFACTOR.md for more details on the completed migration.

## Platforms Supported

- **NixOS**: Desktop and Pocket configurations
- **macOS (Darwin)**: Full system and standalone home-manager configurations

## Usage

### System Configuration

#### NixOS (Linux)
```bash
# Build and switch to the desktop configuration
sudo nixos-rebuild switch --flake .#desktop

# OR for the pocket device
sudo nixos-rebuild switch --flake .#pocket
```

#### macOS (via nix-darwin)
```bash
# Build and switch to the macbook configuration
darwin-rebuild switch --flake .#macbook
```

### Home Manager Configuration (Standalone)

```bash
# For the iris configuration
home-manager switch --flake .#iris
```

## Features

- **Cross-platform**: Common configuration shared between Linux and macOS
- **Terminal**: nushell, zsh, starship prompt, ghostty terminal
- **Desktop**: Hyprland compositor on Linux, Aerospace window manager on macOS
- **Development**: Neovim with LSP, VSCode, language-specific tooling
- **Dotfiles**: Managed by Home Manager for consistent experience across machines

## Helper Functions

The flake.nix includes several helper functions to make system configuration more maintainable:

- **mkNixosSystem**: Creates standardized NixOS configurations
  ```nix
  desktop = mkNixosSystem {
    host = "desktop";
    username = "drakeb";
  };
  ```

- **mkDarwinSystem**: Creates standardized Darwin configurations
  ```nix
  macbook = mkDarwinSystem {
    host = "macbook";
    username = "drakebott";
  };
  ```

- **mkHomeConfig**: Creates standardized home-manager configurations
  ```nix
  (mkHomeConfig {
    username = "drakeb";
    host = "desktop";
    isLinux = true;
  })
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