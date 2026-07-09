{ inputs, pkgs, ... }:
{
  imports = [
    inputs.mac-app-util.homeManagerModules.default
    ./karabiner
    ./libiconv.nix
    ./wallpaper.nix
  ];

  home.packages = with pkgs; [
    cocoapods
    xcodes
  ];
}
