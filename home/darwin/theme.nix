{ lib, pkgs, theme, ... }:
let
  themeInit = import ../common/themeInit.nix {
    darkDetectCmd = ''[[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]'';
    inherit pkgs;
  };
in
{
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore (if theme.appearance == "auto" then themeInit.autoDetect else themeInit.lightExports))
    (lib.mkAfter themeInit.zshSyntaxHighlighting)
  ];
}
