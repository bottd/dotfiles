# Profile for Linux desktop home configuration
{
  config,
  lib,
  paths,
  ...
}: let
  # Import the conditional module
  conditional = import (paths.home + "/utils/conditional.nix") {inherit lib;};
in {
  imports = [
    # Basic features
    (paths.home + "/features")

    # Common modules
    (paths.homeCommon + "/cli.nix")

    # Conditional modules based on features
    (conditional.withFeature config.features.shell.zsh
      (paths.homeCommon + "/zsh.nix"))
    (conditional.withFeature config.features.shell.nushell
      (paths.homeCommon + "/nushell"))
    (conditional.withFeature config.features.editors.neovim
      (paths.homeCommon + "/neovim"))
    (conditional.withFeature config.features.terminal.ghostty
      (paths.homeCommon + "/ghostty.nix"))

    # Language-specific modules
    (paths.homeCommon + "/language")

    # Linux-specific modules
    (paths.homeLinux + "/default.nix")
    (paths.homeLinux + "/desktop.nix")
    (paths.homeLinux + "/hyprland")
  ];

  # Set Linux-specific features
  features = {
    desktop = {
      enable = true;
      gtk = true;
      qt = true;
      cursor = true;
      sound = true;
    };

    shell = {
      zsh = true;
      nushell = true;
    };

    editors = {
      neovim = true;
      vscode = true;
    };

    terminal = {
      ghostty = true;
    };
  };
}
