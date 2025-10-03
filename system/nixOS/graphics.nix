{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      vulkan-headers
    ];
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
}
