{ lib, pkgs, theme, ... }:
let
  themeInit = import ../common/themeInit.nix {
    darkDetectCmd = ''[[ "$(darkman get 2>/dev/null)" == "dark" ]]'';
    inherit pkgs;
  };
in
{
  services.darkman = lib.mkIf (theme.appearance == "auto") {
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
    (lib.mkBefore (if theme.appearance == "auto" then themeInit.autoDetect else themeInit.lightExports))
    (lib.mkAfter themeInit.zshSyntaxHighlighting)
  ];
}
