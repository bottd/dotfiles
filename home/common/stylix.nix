{ lib, colorScheme, stylixTheme, baseFontSize, pkgs, ... }:
let
  scheme = {
    catppuccin = if colorScheme == "light" then "catppuccin-latte" else "catppuccin-mocha";
    eink = ../../lib/schemes/eink.yaml;
  }.${stylixTheme};

  polarity = {
    catppuccin = if colorScheme == "light" then "light" else "dark";
    eink = "light";
  }.${stylixTheme};
in
{
  stylix = {
    enable = lib.mkDefault true;
    base16Scheme = lib.mkDefault scheme;
    polarity = lib.mkDefault polarity;
    autoEnable = lib.mkDefault true;

    fonts = {
      monospace = lib.mkDefault {
        name = "MonoLisa Nerd Font";
        package = pkgs.nerd-fonts.monolisa;
      };
      sizes.terminal = lib.mkDefault baseFontSize;
    };

    targets = {
      # starship is handled manually for runtime light/dark switching
      starship.enable = false;
    };
  };
}
