{ inputs, ... }:
{
  imports = with inputs; [
    steam-config-nix.homeModules.default
    ./steam.nix
    ./minecraft.nix
    ./deadlock.nix
    ./counterstrike.nix
  ];
}
