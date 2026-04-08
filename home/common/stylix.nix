{ lib, theme, pkgs, ... }:
let
  inherit (import ../../lib/stylixScheme.nix { inherit pkgs; inherit (theme) appearance scheme; }) base16Scheme polarity;
in
{
  stylix = {
    enable = lib.mkDefault true;
    base16Scheme = lib.mkDefault base16Scheme;
    polarity = lib.mkDefault polarity;
    autoEnable = lib.mkDefault true;
    image = lib.mkDefault null;

    fonts = {
      monospace = {
        name = lib.mkOptionDefault "MonoLisa Nerd Font";
        # MonoLisa is a commercial font installed outside Nix
        package = lib.mkOptionDefault pkgs.emptyDirectory;
      };
      sizes.terminal = lib.mkOptionDefault theme.baseFontSize;
    };

    targets = {
      firefox.profileNames = [ "default" ];
      mangohud.enable = false;
      neovim.enable = false;
      starship.enable = false;
    };
  };
}
