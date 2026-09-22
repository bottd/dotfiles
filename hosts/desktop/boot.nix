{ config, inputs, ... }:
# systemd-boot can't be themed at all, so the Minecraft world-selection boot
# menu means GRUB. Only this host switches; pocket and eink stay on systemd-boot
# (which is why its `enable` is mkDefault in system/common/linux).
{
  imports = [ inputs.minegrub-world-sel-theme.nixosModules.default ];

  boot.loader = {
    systemd-boot.enable = false;
    # The ESP is mounted separately so GRUB's theme and configuration live on
    # ext4. See docs/desktop-grub-migration.md for the one-time mount transition.
    efi.efiSysMountPoint = "/boot/efi";

    grub = {
      enable = true;
      efiSupport = true;
      # EFI-only box, so there's no BIOS disk to embed a stage-1 into.
      device = "nodev";

      # /boot and /nix/store share ext4, so GRUB can read kernels directly
      # from the store without duplicating them onto the 511 MiB ESP.
      copyKernels = false;
      # Bound the rollback menu independently of ESP capacity.
      configurationLimit = 10;

      # The theme positions its menu in absolute pixels over a 1920x1080
      # background. Left at the default 'auto' GRUB usually picks 1024x768 and
      # crops the menu, so pin the mode the theme was drawn for; both panels are
      # 16:9, so the firmware scales it up without distortion.
      gfxmodeEfi = "1920x1080,auto";

      # systemd-boot finds Windows on its own by spotting
      # /EFI/Microsoft/Boot/bootmgfw.efi on the ESP. GRUB has no equivalent, so
      # without this the Windows 11 entry simply disappears. Declared by hand
      # rather than via useOSProber: os-prober has to mount the NTFS volumes at
      # activation time to guess the same path, and it can't set the --class that
      # the theme reads to pick an icon.
      #
      # `search --file` resolves whichever partition actually holds the loader,
      # so this survives the ESP being re-created or given a new UUID. Windows
      # lives on sda but has no ESP of its own, so that resolves to the NVMe ESP.
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
          # `name` is the GRUB menuentry *class*, not the hostname: the theme
          # resolves icons as icons/<class>.png, and boot.loader.grub's
          # entryOptions defaults to "--class nixos". Upstream's README uses
          # config.system.name here, which on this host is "desktop" and would
          # emit an icons/desktop.png that GRUB never looks up — leaving the
          # theme's stale built-in "Version: 24.11" icon on screen instead.
          name = "nixos";
          lineTop = with config.system.nixos; "${distroName} ${codeName} (${release})";
          lineBottom = with config.system.nixos; "Survival Mode, No Cheats, Version: ${release}";
          imgName = "nixos";
        }];
      };
    };
  };
}
