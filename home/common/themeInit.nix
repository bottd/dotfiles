{ darkDetectCmd, colorSchemes }:
let
  mkFzfColors = palette:
    "--color=bg+:#${palette.base02},bg:#${palette.base00},spinner:#${palette.base06},hl:#${palette.base0D},fg:#${palette.base05},header:#${palette.base0D},info:#${palette.base0E},pointer:#${palette.base06},marker:#${palette.base07},fg+:#${palette.base05},prompt:#${palette.base0E},hl+:#${palette.base0D}";

  mkExports = { flavor, flavorCap }:
    let
      inherit (colorSchemes."catppuccin-${flavor}") palette;
      mode = if flavor == "latte" then "light" else "dark";
    in
    ''
      export CATPPUCCIN_FLAVOR="${flavor}"
      export BAT_THEME="Catppuccin ${flavorCap}"
      export STARSHIP_CONFIG="$HOME/.config/starship/${mode}.toml"
      export FZF_DEFAULT_OPTS="${mkFzfColors palette}"
    '';

  lightExports = mkExports { flavor = "latte"; flavorCap = "Latte"; };
  darkExports = mkExports { flavor = "mocha"; flavorCap = "Mocha"; };

  autoDetect = ''
    if ${darkDetectCmd}; then
    ${darkExports}
    else
    ${lightExports}
    fi
  '';
in
{
  inherit lightExports autoDetect;
}
