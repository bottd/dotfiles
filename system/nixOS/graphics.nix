{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      vulkan-headers
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
      # VAAPI for AMD (hardware video encoding/decoding)
      libva
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
}
