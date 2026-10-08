{
  boot.loader = {
    systemd-boot.enable = false;
    efi.efiSysMountPoint = "/boot/efi";

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";

      # /boot shares ext4 with /nix/store; keep kernel copies off the small ESP.
      copyKernels = false;
      configurationLimit = 10;

      # Explicit entry avoids os-prober.
      extraEntries = ''
        menuentry "Windows 11" --class windows11 {
          insmod part_gpt
          insmod fat
          insmod chain
          search --no-floppy --set=root --file /EFI/Microsoft/Boot/bootmgfw.efi
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };
}
