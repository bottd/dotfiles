{paths, ...}: {
  imports = [
    # Common modules
    ./common
    ./base
    ./users

    # Specialized modules
    ./auto-hostname
    ./bootloader
    ./darwin-base
    ./dev-tools
    ./display-server
    ./features
    ./fonts
    ./intel
    ./nvidia
    ./oom-protection
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

    # Testing modules
    ./testing/validation.nix
    ./testing/unit-tests.nix

    # Profiles for different system types
    ./profiles/desktop-linux.nix
    ./profiles/darwin.nix
  ];
}
