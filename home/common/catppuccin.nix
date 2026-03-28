{ pkgs, inputs, desktopEnvironment, colorScheme, lib, ... }:
let
  flavor = if colorScheme == "light" then "latte" else "mocha";

  baseConfig = {
    inherit flavor;
    accent = "blue";

    bat.enable = true;
    btop.enable = true;
    fish.enable = true;
    fzf.enable = true;
    starship.enable = false;
    zsh-syntax-highlighting.enable = false;

    delta.enable = false;
    lazygit.enable = true;
    gh-dash.enable = true;

    micro.enable = true;
    yazi.enable = true;
    zellij.enable = true;
  };

  guiConfig = {
    cursors = {
      enable = pkgs.stdenv.isLinux;
      inherit flavor;
      accent = "blue";
    };
    kvantum.enable = pkgs.stdenv.isLinux;

    thunderbird = {
      enable = true;
      profile = "drake";
    };
  };
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes."catppuccin-${flavor}";

  catppuccin = baseConfig // lib.optionalAttrs (desktopEnvironment != null) guiConfig;
}
