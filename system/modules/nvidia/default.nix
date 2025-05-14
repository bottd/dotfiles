# NVIDIA-specific hardware configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = ["nvidia"];

  # Hardware acceleration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # NVIDIA settings
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Wayland support
  environment.variables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    nvtop
    nvidia-vaapi-driver
  ];
}
