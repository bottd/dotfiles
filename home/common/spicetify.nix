{ config, pkgs, inputs, lib, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  inherit (config.lib.stylix) colors;
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];
  programs.spicetify = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;

    colorScheme = lib.mkForce "custom";
    customColorScheme = {
      text = colors.base05;
      subtext = colors.base04;
      main = colors.base00;
      sidebar = colors.base01;
      player = colors.base01;
      card = colors.base02;
      shadow = colors.base00;
      selected-row = colors.base03;
      button = colors.base0E;
      button-active = colors.base0E;
      button-disabled = colors.base04;
      tab-active = colors.base0D;
      notification = colors.base0B;
      notification-error = colors.base08;
      misc = colors.base0C;
    };

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle
      hidePodcasts
      adblock
    ];
  };
}
