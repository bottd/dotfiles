{
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    spotify
  ];
}
