# Drake's Flake

This is my personal Nix flake. I use it to manage configurations for my

- NixOS Desktop
- NixOS Pocket Laptop
- MacBook Pros

## Useful commands

- Use [direnv](https://github.com/direnv/direnv) for development
- `nix fmt` to format

### System Configuration

#### NixOS (Linux)

I have a configuration for desktop:

```bash

sudo nixos-rebuild switch --flake .#desktop
```

and my [GPD Pocket 4](https://gpd.hk/gpdpocket4):

```sh
sudo nixos-rebuild switch --flake .#pocket
```

#### MacOS

My personal MacBook uses [nix-darwin]():

```bash
darwin-rebuild switch --flake .#macbook
```

Standalone home-manager configuration for external Macs:

```bash
home-manager switch --flake .#standalone
```
