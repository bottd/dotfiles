{ lib, colorScheme, stylixTheme, baseFontSize, pkgs, ... }:
let
  inherit (import ../../lib/stylixScheme.nix { inherit pkgs colorScheme stylixTheme; }) scheme polarity;
in
{
  stylix = {
    enable = lib.mkDefault true;
    base16Scheme = lib.mkDefault scheme;
    polarity = lib.mkDefault polarity;
    autoEnable = lib.mkDefault true;
    image = lib.mkDefault null;

    fonts = {
      monospace = {
        name = lib.mkOptionDefault "MonoLisa Nerd Font";
        # MonoLisa is a commercial font installed outside Nix
        package = lib.mkOptionDefault pkgs.emptyDirectory;
      };
      sizes.terminal = lib.mkOptionDefault baseFontSize;
    };

    targets = {
      firefox.profileNames = [ "default" ];
      mangohud.enable = false;
      neovim.enable = false;
      starship.enable = false;
    };
  };
}
