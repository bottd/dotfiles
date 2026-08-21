{ inputs, ... }:
{
  imports = with inputs; [
    ./counter-strike.nix
    ./deadlock.nix
    ./steam.nix
    steam-config-nix.homeModules.default
  ];
}
