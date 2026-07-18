{ config, inputs, pkgs, ... }:
let
  colors = config.lib.stylix.colors;
  hex = color: "#${color}";
in
{
  home.packages = [ inputs.opencode.packages.${pkgs.system}.opencode ];

  home.file = {
    ".config/opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      permission.external_directory = {
        "/nix/store/**" = "allow";
        "~/dotfiles/**" = "allow";
        "~/workspace/**" = "allow";
        "~/loam/**" = "allow";
        "~/remote/**" = "allow";
      };
    };
    ".config/opencode/tui.json".text = builtins.toJSON { "$schema" = "https://opencode.ai/tui.json"; theme = "stylix"; };
    ".config/opencode/themes/stylix.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/theme.json";
      theme = {
        primary = hex colors.base0D;
        secondary = hex colors.base0E;
        accent = hex colors.base0C;
        text = hex colors.base07;
        textMuted = hex colors.base04;
        background = hex colors.base00;
        error = hex colors.base08;
        warning = hex colors.base0A;
        success = hex colors.base0B;
        info = hex colors.base0D;
        backgroundPanel = hex colors.base01;
        backgroundElement = hex colors.base02;
        border = hex colors.base03;
        borderActive = hex colors.base0D;
        borderSubtle = hex colors.base02;
        diffAdded = hex colors.base0B;
        diffRemoved = hex colors.base08;
        diffContext = hex colors.base04;
        markdownHeading = hex colors.base0E;
        markdownLink = hex colors.base0D;
        markdownLinkText = hex colors.base0C;
        markdownCode = hex colors.base0B;
        markdownBlockQuote = hex colors.base05;
        markdownEmph = hex colors.base0A;
        markdownStrong = hex colors.base07;
        markdownHorizontalRule = hex colors.base03;
        markdownListItem = hex colors.base0C;
        syntaxComment = hex colors.base04;
        syntaxKeyword = hex colors.base0E;
        syntaxFunction = hex colors.base0D;
        syntaxVariable = hex colors.base08;
        syntaxString = hex colors.base0B;
        syntaxNumber = hex colors.base09;
        syntaxType = hex colors.base0A;
        syntaxOperator = hex colors.base0C;
        syntaxPunctuation = hex colors.base05;
      };
    };
  };
}
