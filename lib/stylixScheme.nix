{ pkgs, appearance, scheme }:
let
  schemes = {
    oxocarbon = "${pkgs.base16-schemes}/share/themes/oxocarbon-${appearance}.yaml";
  };

in
{
  base16Scheme = schemes.${scheme};
  polarity = appearance;
}
