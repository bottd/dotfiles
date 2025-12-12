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
      # VAAPI for AMD (hardware video encoding/decoding)
      libva
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
}
