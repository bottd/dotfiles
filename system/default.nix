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
  ];
}
