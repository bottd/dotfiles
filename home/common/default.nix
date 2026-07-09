{ config, features, lib, ... }:
{
  # Symlink into the live repo checkout instead of the store, so edits apply
  # without a rebuild.
  lib.meta.createSymlink = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";

  imports = [
    ./claude
    ./cli.nix
    ./codex
    ./direnv.nix
    ./git.nix
    ./jujutsu.nix
    ./language.nix
    ./neovim
    ./pi
    ./scripts.nix
    ./starship
    ./stylix.nix
    ./tmux.nix
    ./zellij.nix
    ./zoxide.nix
    ./zsh.nix

    # import GUI modules when desktop environment is present
  ] ++ lib.optionals (features.desktopEnvironment != null) [
    ./browser.nix
    ./ghostty.nix
    ./glide
  ] ++ lib.optionals features.gui [
    ./bitwarden.nix
  ];
}
