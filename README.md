# Drake's NixOS, Darwin & Home Manager Flake

A comprehensive, cross-platform system configuration using Nix Flakes. This repository contains configurations for:

- NixOS (Linux) machines
- macOS machines via nix-darwin
- Home Manager configurations for both platforms

## Structure

Current structure (being migrated to new organization):
```
.
├── darwin/             # macOS system configurations
├── flake.nix           # Main flake definition using flake-parts
├── home.nix            # Base home-manager configuration
├── home/               # Home-manager modules
│   ├── common/         # Cross-platform configurations
│   ├── darwin/         # macOS-specific home configurations
│   └── linux/          # Linux-specific home configurations
├── hosts.nix           # Host registry with machine configurations
├── lib/                # Helper functions for building systems
├── nixOS/              # NixOS system configurations
├── system/             # New location for system configurations
│   ├── modules/        # Shared system modules
│   └── hosts/          # Host-specific configurations
└── util/               # Helper utilities
```

See REFACTOR.md for more details on the in-progress improvements.

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