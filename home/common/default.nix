{ desktopEnvironment ? null, lib, ... }:
{
  imports = [
    ./catppuccin.nix
    ./claude.nix
    ./gemini.nix
    ./cli.nix
    ./devenv.nix
    ./email
    ./git.nix
    ./jujutsu.nix
    ./language.nix
    ./neovim
    ./opencode.nix
    ./scripts.nix
    ./starship
    ./tmux.nix
    ./zellij.nix
    ./zoxide.nix
    ./zsh.nix

    # import GUI modules when desktop environment is present
  ] ++ lib.optionals (desktopEnvironment != null) [
    ./browser.nix
    ./desktop.nix
    ./ghostty.nix
    ./spicetify.nix
  ];
}
