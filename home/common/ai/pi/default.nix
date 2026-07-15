{ config, pkgs, ... }:
let
  colors = config.lib.stylix.colors;
  hex = color: "#${color}";
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
        colors = {
          accent = hex colors.base0D;
          border = hex colors.base03;
          borderAccent = hex colors.base0D;
          borderMuted = hex colors.base02;
          success = hex colors.base0B;
          error = hex colors.base08;
          warning = hex colors.base0A;
          muted = hex colors.base04;
          dim = hex colors.base03;
          text = hex colors.base07;
          thinkingText = hex colors.base05;
          selectedBg = hex colors.base02;
          userMessageBg = hex colors.base01;
          userMessageText = hex colors.base07;
          customMessageBg = hex colors.base01;
          customMessageText = hex colors.base07;
          customMessageLabel = hex colors.base0E;
          toolPendingBg = hex colors.base01;
          toolSuccessBg = hex colors.base01;
          toolErrorBg = hex colors.base01;
          toolTitle = hex colors.base0D;
          toolOutput = hex colors.base06;
          mdHeading = hex colors.base0E;
          mdLink = hex colors.base0D;
          mdLinkUrl = hex colors.base0C;
          mdCode = hex colors.base0B;
          mdCodeBlock = hex colors.base06;
          mdCodeBlockBorder = hex colors.base03;
          mdQuote = hex colors.base05;
          mdQuoteBorder = hex colors.base03;
          mdHr = hex colors.base03;
          mdListBullet = hex colors.base0C;
          toolDiffAdded = hex colors.base0B;
          toolDiffRemoved = hex colors.base08;
          toolDiffContext = hex colors.base04;
          syntaxComment = hex colors.base04;
          syntaxKeyword = hex colors.base0E;
          syntaxFunction = hex colors.base0D;
          syntaxVariable = hex colors.base08;
          syntaxString = hex colors.base0B;
          syntaxNumber = hex colors.base09;
          syntaxType = hex colors.base0A;
          syntaxOperator = hex colors.base0C;
          syntaxPunctuation = hex colors.base05;
          thinkingOff = hex colors.base04;
          thinkingMinimal = hex colors.base0D;
          thinkingLow = hex colors.base0C;
          thinkingMedium = hex colors.base0B;
          thinkingHigh = hex colors.base0A;
          thinkingXhigh = hex colors.base09;
          thinkingMax = hex colors.base08;
          bashMode = hex colors.base09;
        };
      };
    };
  };

  programs.git.ignores = [ ".pi/settings.json" ];
}
