# Common boot configuration for NixOS systems
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      enable = false;
    };
  };
}
