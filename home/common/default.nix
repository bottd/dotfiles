{ features, lib, ... }:
{

  imports = [
    ./claude
    ./cli.nix
    ./codex
    ./direnv.nix
    ./email
    ./gemini.nix
    ./git.nix
    ./jujutsu.nix
    ./language.nix
    ./neovim
    ./opencode.nix
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
    ./spicetify.nix
  ] ++ lib.optionals features.gui [
    ./bitwarden.nix
  ];
}
