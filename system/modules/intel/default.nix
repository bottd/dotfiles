# Intel-specific hardware configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Graphics
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # CPU microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # Power management
  services.thermald.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # System packages
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    thermald
  ];
}
