{ lib, colorScheme, stylixTheme, baseFontSize, pkgs, ... }:
let
  scheme = {
    catppuccin = "${pkgs.base16-schemes}/share/themes/catppuccin-${if colorScheme == "light" then "latte" else "mocha"}.yaml";
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
    image = lib.mkDefault null;

    fonts = {
      monospace = {
        name = lib.mkOptionDefault "MonoLisa Nerd Font";
        package = lib.mkOptionDefault pkgs.emptyDirectory;
      };
      sizes.terminal = lib.mkOptionDefault baseFontSize;
    };

    targets = {
      # mangohud has custom non-color settings that conflict with Stylix defaults
      mangohud.enable = false;
      # neovim config is managed by rocks.nvim, avoid init.lua conflict
      neovim.enable = false;
      # starship is handled manually for runtime light/dark switching
      starship.enable = false;
    };
  };
}
