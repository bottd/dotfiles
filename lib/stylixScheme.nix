{ pkgs, appearance, scheme }:
let
  schemes = {
    tokyonight = "${pkgs.base16-schemes}/share/themes/tokyo-night-${if appearance == "light" then "light" else "storm"}.yaml";
    solarized = "${pkgs.base16-schemes}/share/themes/solarized-${appearance}.yaml";
  };

in
{
  base16Scheme = schemes.${scheme};
  polarity = appearance;
}
