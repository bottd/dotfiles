# Home-manager features module for configuring user environment capabilities
{
  lib,
  config,
  ...
}: {
  options.features = {
    # Desktop environment features
    desktop = {
      enable = lib.mkEnableOption "Enable desktop environment features";
      gtk = lib.mkEnableOption "Enable GTK theming and integration";
      qt = lib.mkEnableOption "Enable Qt theming and integration";
      cursor = lib.mkEnableOption "Enable custom cursor theme";
      sound = lib.mkEnableOption "Enable sound configuration";
    };

    # Shell features
    shell = {
      bash = lib.mkEnableOption "Enable Bash configuration";
      zsh = lib.mkEnableOption "Enable Zsh configuration";
      nushell = lib.mkEnableOption "Enable NuShell configuration";
      fish = lib.mkEnableOption "Enable Fish configuration";
    };

    # Editor features
    editors = {
      neovim = lib.mkEnableOption "Enable Neovim configuration";
      vscode = lib.mkEnableOption "Enable VSCode configuration";
      emacs = lib.mkEnableOption "Enable Emacs configuration";
    };

    # Development features
    dev = {
      enable = lib.mkEnableOption "Enable development tools";
      python = lib.mkEnableOption "Enable Python development tools";
      rust = lib.mkEnableOption "Enable Rust development tools";
      node = lib.mkEnableOption "Enable Node.js development tools";
      go = lib.mkEnableOption "Enable Go development tools";
      git = lib.mkEnableOption "Enable Git configuration";
    };

    # Terminal features
    terminal = {
      ghostty = lib.mkEnableOption "Enable Ghostty terminal configuration";
      wezterm = lib.mkEnableOption "Enable WezTerm terminal configuration";
      kitty = lib.mkEnableOption "Enable Kitty terminal configuration";
      alacritty = lib.mkEnableOption "Enable Alacritty terminal configuration";
    };
  };

  # Default values
  config = {
    # Desktop defaults (platform-specific)
    features.desktop = lib.mkIf (lib.hasInfix "linux" config.home.sessionVariables.NAME) {
      enable = true;
      gtk = true;
      qt = true;
      cursor = true;
      sound = true;
    };

    # Shell defaults
    features.shell = {
      bash = false;
      zsh = true;
      nushell = true;
      fish = false;
    };

    # Editor defaults
    features.editors = {
      neovim = true;
      vscode = true;
      emacs = false;
    };

    # Development defaults
    features.dev = {
      enable = true;
      python = false;
      rust = false;
      node = false;
      go = false;
      git = true;
    };

    # Terminal defaults
    features.terminal = {
      ghostty = true;
      wezterm = false;
      kitty = false;
      alacritty = false;
    };
  };
}
