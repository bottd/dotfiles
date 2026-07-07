# dotfiles

Starter flake (macOS)

- **`.#darwin`** — system managed with
  [nix-darwin](https://github.com/nix-darwin/nix-darwin) (system defaults +
  home-manager). Use this on a Mac where you have admin rights.
- **`.#standalone`** — user-level only, via standalone
  [home-manager](https://github.com/nix-community/home-manager). Use this on a
  locked-down machine (e.g. a work Mac) where you can't install nix-darwin.

Both share everything under `home/`.

## Setup

1. Clone this repo to `~/dotfiles` (the path a couple of symlinks assume).
2. Set your username in `outputs/hosts.nix` and your name/email in
   `home/common/git.nix`.
3. Deploy:

```bash
# nix-darwin:
darwin-rebuild switch --flake .#darwin

# standalone:
home-manager switch --flake .#standalone
```

## Layout

```
flake.nix              inputs + flake-parts entry
outputs/               flake outputs: hosts.nix (the two configs), formatter
lib/                   mkSystem (nix-darwin) + mkHome (standalone) builders
hosts/darwin/          per-host system config
home/common/           home-manager modules shared by both configs
home/darwin/           macOS-only home-manager modules
system/common/darwin/  nix-darwin system config (dock, finder, nix)
```

`nix fmt` formats the tree (nixpkgs-fmt + deadnix + statix).
