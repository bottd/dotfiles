# Hardware configuration module that uses the config system
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Get the module configuration
  cfg = moduleSystem.getModuleConfig config.sysConfig.hardware;

  # Helper to check if a feature is enabled
  isEnabled = feature: cfg.${feature} or false;
in {
  config = lib.mkMerge [
    # CPU-specific configuration
    (lib.mkIf (cfg.cpuType == "intel") {
      hardware.cpu.intel.updateMicrocode = true;
      powerManagement.cpuFreqGovernor = "powersave";

      # Add Intel-specific packages
      environment.systemPackages = with pkgs; [
        intel-gpu-tools
        thermald
      ];

      # Enable thermald for Intel CPUs
      services.thermald.enable = true;
    })

    (lib.mkIf (cfg.cpuType == "amd") {
      hardware.cpu.amd.updateMicrocode = true;
      powerManagement.cpuFreqGovernor = "powersave";

      # Add AMD-specific packages
      environment.systemPackages = with pkgs; [
        zenmonitor
        zenpower
      ];
    })

    # GPU-specific configuration
    (lib.mkIf (cfg.gpuType == "nvidia") {
      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      environment.variables = {
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
      };

      environment.systemPackages = with pkgs; [
        nvtop
        nvidia-vaapi-driver
      ];
    })

    (lib.mkIf (cfg.gpuType == "amd") {
      services.xserver.videoDrivers = ["amdgpu"];
      hardware.opengl.extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];

      environment.systemPackages = with pkgs; [
        radeontop
      ];
    })

    (lib.mkIf (cfg.gpuType == "intel") {
      hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    })

    # OpenGL configuration
    (lib.mkIf (isEnabled "opengl") {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    })

    # Bluetooth configuration
    (lib.mkIf (isEnabled "bluetooth") {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      services.blueman.enable = true;

      environment.systemPackages = with pkgs; [
        bluez
        bluez-tools
        blueman
      ];
    })

    # Printing configuration
    (lib.mkIf (isEnabled "printing") {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          gutenprint
          gutenprintBin
          hplip
          epson-escpr
          canon-cups-ufr2
        ];
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        system-config-printer
      ];
    })

    # Sound configuration
    (lib.mkIf (isEnabled "sound") {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        helvum
      ];
    })

    # Virtualization configuration
    (lib.mkIf (isEnabled "virtualization") {
      virtualisation = {
        libvirtd.enable = true;
        docker.enable = true;
        podman.enable = true;
      };

      environment.systemPackages = with pkgs; [
        virt-manager
        qemu
        docker-compose
      ];

      # Add user to virtualization groups
      users.users.${config.sysConfig.user.defaults.name}.extraGroups = [
        "libvirtd"
        "docker"
      ];
    })
  ];
}
