{ inputs, ... }:
{
  imports = [
    inputs.mac-app-util.homeManagerModules.default
    ../common/ghostty.nix
    ./dev.nix
    ./karabiner
    ./libiconv.nix
    ./wallpaper.nix
  ];
}
