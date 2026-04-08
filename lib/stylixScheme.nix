{ pkgs, colorScheme, stylixTheme }:
{
  scheme = {
    catppuccin = "${pkgs.base16-schemes}/share/themes/catppuccin-${if colorScheme == "light" then "latte" else "mocha"}.yaml";
    eink = "${pkgs.base16-schemes}/share/themes/solarized-light.yaml";
  }.${stylixTheme};

  polarity = {
    catppuccin = if colorScheme == "light" then "light" else "dark";
    eink = "light";
  }.${stylixTheme};
}
