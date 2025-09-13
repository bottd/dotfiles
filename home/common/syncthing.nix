{ pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    tray.enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}
