{ inputs, pkgs, ... }:
{
  # Cauldron (䷱), the Mog desktop vault editor. The package ships its own
  # desktop entry and hicolor icons, so it shows up in launchers as-is.
  home.packages = [
    inputs.mog.packages.${pkgs.stdenv.hostPlatform.system}.cauldron
  ];
}
