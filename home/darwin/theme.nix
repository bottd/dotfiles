{ lib, pkgs, inputs, colorScheme, ... }:
let
  catppuccinZshSyntax = inputs.catppuccin.packages.${pkgs.system}.zsh-syntax-highlighting;
  themeInit = import ../common/themeInit.nix {
    darkDetectCmd = ''[[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]'';
    inherit (inputs.nix-colors) colorSchemes;
  };
in
{
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore (if colorScheme == "auto" then themeInit.autoDetect else themeInit.lightExports))
    (lib.mkAfter ''
      source "${catppuccinZshSyntax}/catppuccin_''${CATPPUCCIN_FLAVOR:-latte}-zsh-syntax-highlighting.zsh"
    '')
  ];
}
