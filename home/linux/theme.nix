{ lib, pkgs, colorScheme, ... }:
let
  catppuccinZshSyntax = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zsh-syntax-highlighting";
    rev = "main";
    hash = "sha256-YjVLEiSMkGVsgB5ZGGWU3FhMp04J3NKZP2jJBRTMCk=";
  };
  themeInit = import ../common/themeInit.nix {
    darkDetectCmd = ''[[ "$(darkman get 2>/dev/null)" == "dark" ]]'';
    inherit catppuccinZshSyntax;
  };
in
{
  services.darkman = lib.mkIf (colorScheme == "auto") {
    enable = true;
    settings.usegeoclue = true;

    darkModeScripts.gtk-theme = ''
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    '';

    lightModeScripts.gtk-theme = ''
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    '';
  };

  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore (if colorScheme == "auto" then themeInit.autoDetect else themeInit.lightExports))
    (lib.mkAfter themeInit.zshSyntaxHighlighting)
  ];
}
