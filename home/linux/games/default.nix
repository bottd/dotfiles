{ inputs, ... }:
{
  imports = with inputs; [
    ./counter-strike.nix
    ./deadlock.nix
    ./minecraft.nix
    ./steam.nix
    steam-config-nix.homeModules.default
  ];
}
