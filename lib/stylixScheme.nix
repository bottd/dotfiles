{ pkgs, appearance, scheme }:
let
  schemeName =
    # The regular Tinted pair puts red in base0F; the terminal pair follows
    # conventional Base16 semantics used by Stylix's error and diff targets.
    if scheme == "tokyo-night"
    then "tokyo-night-terminal-${appearance}"
    else if scheme == "primer"
    then "primer-${appearance}"
    else scheme;
in
{
  base16Scheme = "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";
  polarity = appearance;
}
