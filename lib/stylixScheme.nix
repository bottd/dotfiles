{ pkgs, appearance, scheme }:
let
  schemes = {
    catppuccin = "${pkgs.base16-schemes}/share/themes/catppuccin-${if appearance == "light" then "latte" else "mocha"}.yaml";
    eink = "${pkgs.base16-schemes}/share/themes/solarized-light.yaml";
  };

  polarities = {
    catppuccin = if appearance == "light" then "light" else "dark";
    eink = "light";
  };
in
{
  base16Scheme = schemes.${scheme};
  polarity = polarities.${scheme};
}
