{ darkDetectCmd }:
let
  lightExports = ''
    export CATPPUCCIN_FLAVOR="latte"
    export BAT_THEME="Catppuccin Latte"
    export STARSHIP_CONFIG="$HOME/.config/starship/light.toml"
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#1e66f5,fg:#4c4f69,header:#1e66f5,info:#1e66f5,pointer:#1e66f5,marker:#1e66f5,fg+:#4c4f69,prompt:#1e66f5,hl+:#1e66f5"
  '';

  darkExports = ''
    export CATPPUCCIN_FLAVOR="mocha"
    export BAT_THEME="Catppuccin Mocha"
    export STARSHIP_CONFIG="$HOME/.config/starship/dark.toml"
  '';

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
