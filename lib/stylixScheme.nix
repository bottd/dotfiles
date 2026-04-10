{ pkgs, appearance, scheme }:
let
  schemes = {
    tokyonight = "${pkgs.base16-schemes}/share/themes/tokyo-night-${if appearance == "light" then "light" else "storm"}.yaml";
    solarized = "${pkgs.base16-schemes}/share/themes/solarized-${appearance}.yaml";
  };

  polarities = {
    tokyonight = if appearance == "light" then "light" else "dark";
    solarized = appearance;
  };
in
{
  base16Scheme = schemes.${scheme};
  polarity = polarities.${scheme};
}
