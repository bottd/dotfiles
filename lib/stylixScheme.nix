{ pkgs, colorScheme, stylixTheme }:
{
  scheme = {
    catppuccin = "${pkgs.base16-schemes}/share/themes/catppuccin-${if colorScheme == "light" then "latte" else "mocha"}.yaml";
    eink = ../lib/schemes/eink.yaml;
  }.${stylixTheme};

  polarity = {
    catppuccin = if colorScheme == "light" then "light" else "dark";
    eink = "light";
  }.${stylixTheme};
}
