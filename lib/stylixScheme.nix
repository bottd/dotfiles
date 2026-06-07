{ pkgs, appearance, scheme }:
let
  base16 = "${pkgs.base16-schemes}/share/themes";
  # base16-schemes ships everforest dark but no light variant, so both medium
  # palettes are vendored in ./schemes to keep light/dark symmetric and explicit.
  schemes = {
    everforest = {
      dark = ./schemes/everforest-dark-medium.yaml;
      light = ./schemes/everforest-light-medium.yaml;
    };
  };
  selected = schemes.${scheme} or null;
in
{
  base16Scheme =
    if selected != null
    then selected.${appearance}
    else "${base16}/${scheme}.yaml";
  polarity = appearance;
}
