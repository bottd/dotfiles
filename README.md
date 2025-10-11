# dotfiles

My personal nix flake.

## Targets

### NixOS (Linux)

I have a configuration for my gaming desktop:

```bash

sudo nixos-rebuild switch --flake .#desktop
```

e-ink desktop using [Dasung Paperlike](https://shop.dasung.com/)

```sh
sudo nixos-rebuild switch --flake .#eink
```

my [GPD Pocket 4](https://gpd.hk/gpdpocket4):

```sh
sudo nixos-rebuild switch --flake .#pocket
```

### MacOS

My personal MacBook uses [nix-darwin](https://github.com/nix-darwin/nix-darwin):

```bash
darwin-rebuild switch --flake .#macbook
```

### Android

My
[Pixel 9 Pro Fold](https://store.google.com/us/product/pixel_9_pro_fold?hl=en-US)
uses [nixos-avf](https://github.com/nix-community/nixos-avf) on Android's Native
Linux terminal:

```bash
sudo nixos-rebuild switch --flake .#android
```

### Standalone

Standalone home-manager configuration:

```bash
home-manager switch --flake .#standalone
```
