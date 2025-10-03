{ pkgs, inputs, desktopEnvironment ? null, lib, ... }:
let
  baseConfig = {
    flavor = "mocha";
    accent = "blue";

    bat.enable = true;
    btop.enable = true;
    fish.enable = true;
    fzf.enable = true;
    starship.enable = true;
    zsh-syntax-highlighting.enable = true;

    delta.enable = true;
    lazygit.enable = true;
    gh-dash.enable = true;

    micro.enable = true;
    yazi.enable = true;
    zellij.enable = true;
  };

  guiConfig = {
    cursors = {
      enable = pkgs.stdenv.isLinux;
      flavor = "mocha";
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
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;

  catppuccin = baseConfig // lib.optionalAttrs (desktopEnvironment != null) guiConfig;
}
