{ pkgs, appearance, scheme }:
let
  schemes = {
    tokyonight = "${pkgs.base16-schemes}/share/themes/tokyo-night-${if appearance == "light" then "light" else "storm"}.yaml";
    solarized-light = "${pkgs.base16-schemes}/share/themes/solarized-light.yaml";
  };

  polarities = {
    tokyonight = if appearance == "light" then "light" else "dark";
    solarized-light = "light";
  };
in
{
  base16Scheme = schemes.${scheme};
  polarity = polarities.${scheme};
}
