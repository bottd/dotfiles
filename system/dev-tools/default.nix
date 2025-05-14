# Common development tools for the system level
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Version control
    git

    # Core development tools
    gcc
    gnumake
    cmake

    # System tools
    lsof
    htop

    # Nix tools
    nixfmt
    nix-tree
    nix-index

    # Network tools
    curl
    wget
    inetutils

    # Compression and archiving
    zip
    unzip
    p7zip

    # Terminal utilities
    tree
    ripgrep
    fd
    jq

    # Text editors
    vim
    neovim
  ];

  # Support for man pages
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };

  # Allow direnv for development environments
  programs.direnv.enable = true;
}
