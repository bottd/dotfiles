{ desktopEnvironment ? null, lib, ... }:
{
  imports = [
    ./catppuccin.nix
    ./claude.nix
    ./gemini.nix
    ./cli.nix
    ./devenv.nix
    ./git.nix
    ./jujutsu.nix
    ./language.nix
    ./neovim
    ./scripts.nix
    ./starship
    ./zellij.nix
    ./zoxide.nix
    ./zsh.nix

    # import GUI modules when desktop environment is present
  ] ++ lib.optionals (desktopEnvironment != null) [
    ./desktop.nix
    ./ghostty.nix
    ./spicetify.nix
  ];
}
