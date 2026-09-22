{ config, inputs, ... }:
{
  imports = [ inputs.minegrub-world-sel-theme.nixosModules.default ];

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

      # The theme uses fixed 1920x1080 coordinates.
      gfxmodeEfi = "1920x1080,auto";

      # Explicit entry avoids os-prober and selects the theme's Windows icon.
      extraEntries = ''
        menuentry "Windows 11" --class windows11 {
          insmod part_gpt
          insmod fat
          insmod chain
          search --no-floppy --set=root --file /EFI/Microsoft/Boot/bootmgfw.efi
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';

      minegrub-world-sel = {
        enable = true;
        customIcons = [{
          # Must match the menuentry class, not the hostname.
          name = "nixos";
          lineTop = with config.system.nixos; "${distroName} ${codeName} (${release})";
          lineBottom = with config.system.nixos; "Survival Mode, No Cheats, Version: ${release}";
          imgName = "nixos";
        }];
      };
    };
  };
}
