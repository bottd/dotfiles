{
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gamemode
    gamescope
    mangohud
  ];
}
