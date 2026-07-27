{ pkgs, appearance, scheme }:
let
  schemeName =
    if scheme == "catppuccin"
    then (if appearance == "light" then "catppuccin-latte" else "catppuccin-mocha")
    else if scheme == "primer"
    then "primer-${appearance}"
    else scheme;
in
{
  base16Scheme = "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";
  polarity = appearance;
}
