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
  # bitwarden-desktop pins an Electron flagged insecure by nixpkgs
  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];
  networking.networkmanager.enable = true;

  nix.settings.trusted-users = [ "root" username ];

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    podman-desktop
  ];

  programs.nix-ld.enable = true;
}
