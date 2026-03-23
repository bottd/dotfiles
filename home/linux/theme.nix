{ lib, pkgs, inputs, colorScheme ? "light", ... }:
let
  catppuccinZshSyntax = inputs.catppuccin.packages.${pkgs.system}.zsh-syntax-highlighting;
  themeInit = import ../common/themeInit.nix {
    darkDetectCmd = ''[[ "$(darkman get 2>/dev/null)" == "dark" ]]'';
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
    (lib.mkAfter ''
      source "${catppuccinZshSyntax}/catppuccin_''${CATPPUCCIN_FLAVOR:-latte}-zsh-syntax-highlighting.zsh"
    '')
  ];
}
