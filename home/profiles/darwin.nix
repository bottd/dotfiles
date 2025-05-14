# Profile for Darwin (macOS) home configuration
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

    # Darwin-specific modules
    (paths.homeDarwin + "/default.nix")
    (paths.homeDarwin + "/dev.nix")
    (paths.homeDarwin + "/aerospace")
    (paths.homeDarwin + "/karabiner")
  ];

  # Set Darwin-specific features
  features = {
    desktop = {
      enable = false; # macOS handles the desktop
      gtk = false;
      qt = false;
      cursor = false;
      sound = false;
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
