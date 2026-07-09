{ pkgs, appearance, scheme }:
{
  # base16-schemes ships everforest dark but no light variant, so both medium
  # palettes are vendored in ./schemes to keep light/dark symmetric and explicit.
  base16Scheme =
    if scheme == "everforest"
    then ./schemes/everforest-${appearance}-medium.yaml
    else "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
  polarity = appearance;
}
