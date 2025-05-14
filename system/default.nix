{...}: {
  imports = [
    # Common modules
    ./common
    ./base
    ./users

    # Specialized modules
    ./darwin-base
    ./dev-tools
    ./display-server
    ./features
    ./wayland
    ./hyprland

    # Utility modules
    ./utils/conditional.nix
    ./utils/module-system.nix

    # Configuration system
    ./config
    ./config/hardware.nix
    ./config/desktop.nix
    ./config/networking.nix
    ./config/development.nix
    ./config/user.nix
    ./config/security.nix
  ];
}
