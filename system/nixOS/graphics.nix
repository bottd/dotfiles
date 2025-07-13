{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      vulkan-headers
    ];

    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
}
