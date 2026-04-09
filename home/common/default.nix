{ features, lib, ... }:
{
  imports = [
    ./claude.nix
    ./cli.nix
    ./direnv.nix
    ./email
    ./gemini.nix
    ./git.nix
    ./jujutsu.nix
    ./language.nix
    ./neovim
    ./opencode.nix
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
    ./desktop.nix
    ./ghostty.nix
    ./glide
    ./spicetify.nix
  ];
}
