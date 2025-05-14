# Desktop Linux profile combining common desktop Linux modules
{paths, ...}: {
  imports = [
    # Basic system
    (paths.systemModules + "/base")
    (paths.systemModules + "/common/linux")
    (paths.systemModules + "/users")
    (paths.systemModules + "/auto-hostname")

    # Hardware support
    (paths.systemModules + "/bootloader")
    (paths.systemModules + "/oom-protection")

    # Desktop environment
    (paths.systemModules + "/display-server")
    (paths.systemModules + "/wayland")
    (paths.systemModules + "/hyprland")

    # Additional modules
    (paths.systemModules + "/fonts")
    (paths.systemModules + "/dev-tools")
  ];
}
