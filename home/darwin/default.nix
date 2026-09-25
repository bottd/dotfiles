{ inputs, pkgs, ... }:
{
  imports = [
    inputs.mac-app-util.homeManagerModules.default
    ./karabiner
    ./libiconv.nix
    ./sign-apps.nix
    ./tailscale.nix
    ./wallpaper.nix
  ];

  home.packages = with pkgs; [
    cocoapods
    xcodes
  ];
}
