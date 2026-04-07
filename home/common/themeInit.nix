{ darkDetectCmd }:
let
  # Hardcoded catppuccin base16 palettes for runtime switching
  # These are stable values from the catppuccin base16 schemes
  palettes = {
    latte = {
      base00 = "eff1f5";
      base01 = "e6e9ef";
      base02 = "ccd0da";
      base03 = "bcc0cc";
      base04 = "acb0be";
      base05 = "4c4f69";
      base06 = "dc8a78";
      base07 = "7287fd";
      base08 = "d20f39";
      base09 = "fe640b";
      base0A = "df8e1d";
      base0B = "40a02b";
      base0C = "179299";
      base0D = "1e66f5";
      base0E = "8839ef";
      base0F = "dd7878";
    };
    mocha = {
      base00 = "1e1e2e";
      base01 = "181825";
      base02 = "313244";
      base03 = "45475a";
      base04 = "585b70";
      base05 = "cdd6f4";
      base06 = "f5e0dc";
      base07 = "b4befe";
      base08 = "f38ba8";
      base09 = "fab387";
      base0A = "f9e2af";
      base0B = "a6e3a1";
      base0C = "94e2d5";
      base0D = "89b4fa";
      base0E = "cba6f7";
      base0F = "f2cdcd";
    };
  };

  mkFzfColors = palette:
    "--color=bg+:#${palette.base02},bg:#${palette.base00},spinner:#${palette.base06},hl:#${palette.base0D},fg:#${palette.base05},header:#${palette.base0D},info:#${palette.base0E},pointer:#${palette.base06},marker:#${palette.base07},fg+:#${palette.base05},prompt:#${palette.base0E},hl+:#${palette.base0D}";

  mkExports = { flavor, flavorCap }:
    let
      palette = palettes.${flavor};
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
