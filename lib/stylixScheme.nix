{ pkgs, appearance, scheme }:
let
  melange = {
    dark = {
      base00 = "292522";
      base01 = "34302C";
      base02 = "403A36";
      base03 = "867462";
      base04 = "C1A78E";
      base05 = "ECE1D7";
      base06 = "F1E9E1";
      base07 = "F7F1EB";
      base08 = "D47766";
      base09 = "E49B5D";
      base0A = "EBC06D";
      base0B = "85B695";
      base0C = "89B3B6";
      base0D = "A3A9CE";
      base0E = "CF9BC2";
      base0F = "BD8183";
    };
    light = {
      base00 = "F1F1F1";
      base01 = "E9E1DB";
      base02 = "D9D3CE";
      base03 = "A98A78";
      base04 = "7D6658";
      base05 = "54433A";
      base06 = "3E2F28";
      base07 = "2A1F1A";
      base08 = "BF0021";
      base09 = "BC5C00";
      base0A = "A06D00";
      base0B = "3A684A";
      base0C = "3D6568";
      base0D = "465AA4";
      base0E = "904180";
      base0F = "C77B8B";
    };
  };

  schemeName =
    if scheme == "catppuccin"
    then (if appearance == "light" then "catppuccin-latte" else "catppuccin-mocha")
    else if scheme == "primer"
    then "primer-${appearance}"
    else scheme;
in
{
  base16Scheme =
    if scheme == "melange"
    then melange.${appearance}
    else "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";
  polarity = appearance;
}
