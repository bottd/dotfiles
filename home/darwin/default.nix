{ inputs, ... }:
{
  imports = [
    inputs.mac-app-util.homeManagerModules.default
    ./dev.nix
    ./libiconv.nix
    ./karabiner
    ./sketchybar.nix
    ./theme.nix
    ./wallpaper.nix
    ../common/ghostty.nix
  ];
}
