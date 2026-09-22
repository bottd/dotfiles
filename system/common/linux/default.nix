{ lib, pkgs, username, ... }:
{
  imports = [
    ./oom-management.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        # mkDefault so a host can swap loaders: desktop boots GRUB for the
        # minegrub theme, and only one loader can own the ESP.
        enable = lib.mkDefault true;
        editor = false;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
    };

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
    };
  };

  zramSwap.enable = true;

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  nix.settings.trusted-users = [ "root" username ];

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    podman-desktop
  ];

  programs.nix-ld.enable = true;
}
