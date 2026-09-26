{ config, inputs, pkgs, ... }:
let
  seo = pkgs.callPackage ../seo/package.nix { };
  colors = config.lib.stylix.colors.withHashtag;
in
{
  # stylix's opencode target assumes a dark scheme: its `light` variant maps
  # background to base06, so a light scheme renders dark-on-dark once opencode
  # detects a light terminal. Use one mode-independent palette instead.
  stylix.targets.opencode.enable = false;

  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    settings = {
      mcp.seo = {
        type = "local";
        command = [ "${seo}/bin/seo" "mcp" "serve" ];
        enabled = true;
      };
      permission.external_directory = {
        "/nix/store/**" = "allow";
        "/tmp/**" = "allow";
        "~/dotfiles/**" = "allow";
        "~/workspace/**" = "allow";
        "~/loam/**" = "allow";
        "~/remote/**" = "allow";
        "~/.claude/**" = "allow";
        "~/.codex/**" = "allow";
        "~/.config/opencode/**" = "allow";
      };
    };

    tui.theme = "stylix";
    themes.stylix.theme = with colors; {
      primary = base0D;
      secondary = base0E;
      accent = base0C;
      text = base07;
      textMuted = base04;
      background = base00;
      error = base08;
      warning = base0A;
      success = base0B;
      info = base0D;
      backgroundPanel = base01;
      backgroundElement = base02;
      border = base03;
      borderActive = base0D;
      borderSubtle = base02;
      diffAdded = base0B;
      diffRemoved = base08;
      diffContext = base04;
      markdownHeading = base0E;
      markdownLink = base0D;
      markdownLinkText = base0C;
      markdownCode = base0B;
      markdownBlockQuote = base05;
      markdownEmph = base0A;
      markdownStrong = base07;
      markdownHorizontalRule = base03;
      markdownListItem = base0C;
      syntaxComment = base04;
      syntaxKeyword = base0E;
      syntaxFunction = base0D;
      syntaxVariable = base08;
      syntaxString = base0B;
      syntaxNumber = base09;
      syntaxType = base0A;
      syntaxOperator = base0C;
      syntaxPunctuation = base05;
    };
  };
}
