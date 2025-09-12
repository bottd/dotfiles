{ desktopEnvironment ? null, lib, ... }:
{
  imports = [
    ./claude.nix
    ./cli.nix
    ./git.nix
    ./jujutsu.nix
    ./language.nix
    ./neovim
    ./starship
    ./zellij.nix
    ./zoxide.nix
    ./zsh.nix

    # import GUI modules when desktop environment is present
  ] ++ lib.optionals (desktopEnvironment != null) [
    ./catppuccin.nix
    ./desktop.nix
    ./ghostty.nix
    ./spicetify.nix
    ./vscode.nix
  ];
}
