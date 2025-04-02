{
  inputs,
  lib,
  nixpkgs,
  pkgs,
  system,
  ...
}: {
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${system}".default
  ];
}
