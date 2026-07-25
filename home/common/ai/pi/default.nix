{ config, pkgs, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  home = {
    packages = [ pkgs.pi-coding-agent ];

    file = {
      # Mutable symlink so `/settings` and `pi config` edits land back in
      # this repo (git-tracked). Sessions/auth stay in ~/.pi/agent/.
      ".pi/agent/settings.json".source =
        config.lib.meta.createSymlink "home/common/ai/pi/settings.json";

      ".pi/agent/themes/stylix.json".text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
        name = "stylix";
        colors = (import ../../../../lib/agentTheme.nix colors) // {
          thinkingMax = "#${colors.base08}";
        };
      };
    };
  };

  programs.git.ignores = [ ".pi/settings.json" ];
}
