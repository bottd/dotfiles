{ pkgs, username, ... }:
{
  imports = [
    ./boot.nix
    ./oom-management.nix
  ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
  };

  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;

  nix.settings.trusted-users = [ "root" username ];

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    podman-desktop
  ];
}
