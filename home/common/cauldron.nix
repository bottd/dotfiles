{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.cauldron.packages.${pkgs.stdenv.hostPlatform.system}.cauldron
  ];
}
