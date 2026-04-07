{ lib, pkgs, colorScheme, ... }:
let
  catppuccinZshSyntax = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zsh-syntax-highlighting";
    rev = "main";
    hash = "sha256-YjVLEiSMkGVsgB5ZGGWU3FhMp04J3NKZP2jJBRTMCk=";
  };
  themeInit = import ../common/themeInit.nix {
    darkDetectCmd = ''[[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]'';
  };
in
{
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore (if colorScheme == "auto" then themeInit.autoDetect else themeInit.lightExports))
    (lib.mkAfter ''
      source "${catppuccinZshSyntax}/themes/catppuccin_''${CATPPUCCIN_FLAVOR:-latte}-zsh-syntax-highlighting.zsh"
    '')
  ];
}
