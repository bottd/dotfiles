{ colorScheme, stylixTheme, baseFontSize, pkgs, ... }:
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
    enable = true;
    base16Scheme = scheme;
    inherit polarity;
    autoEnable = true;
    image = null;

    fonts = {
      monospace = {
        name = "MonoLisa Nerd Font";
        package = pkgs.emptyDirectory;
      };
      sizes.terminal = baseFontSize;
    };

    targets.grub.enable = false;

    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
  };
}
