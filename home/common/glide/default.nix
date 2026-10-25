{
  config,
  inputs,
  pkgs,
  nixpkgs-unstable,
  ...
}:
let
  inherit (config.lib.stylix) colors;

  # Dither Press tokens, shared by the chrome (press.css) and the new tab page.
  pressTokens = pkgs.writeText "press-palette.css" ''
    :root {
      --press-paper: #${colors.base00};
      --press-surface: #${colors.base01};
      --press-hover: #${colors.base02};
      --press-rule: #${colors.base03};
      --press-muted: #${colors.base04};
      --press-ink: #${colors.base07};
      --press-plate: #${colors.base09};
      --press-danger: #${colors.base08};
      --press-font: ${builtins.toJSON config.stylix.fonts.monospace.name};
    }
  '';

  pages = pkgs.callPackage ./pages { inherit pressTokens; };
in
{
  imports = [ inputs.glide.homeModules.default ];

  programs.glide-browser = {
    enable = true;

    package = nixpkgs-unstable.wrapFirefox (
      inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.glide-browser-bin-unwrapped.override
        {
          inherit (config.programs.glide-browser) policies;
        }
    ) { pname = "glide-browser-bin"; };

    policies.SearchEngines = {
      Default = "Kagi";
      Remove = [
        "Google"
        "Bing"
        "DuckDuckGo"
        "Amazon.com"
        "eBay"
        "Wikipedia (en)"
        "Perplexity"
      ];
      Add = [
        {
          Name = "Kagi";
          URLTemplate = "https://kagi.com/search?q={searchTerms}";
          Method = "GET";
          IconURL = "https://kagi.com/favicon.ico";
          SuggestURLTemplate = "https://kagi.com/api/autosuggest?q={searchTerms}";
          Alias = "kagi";
        }
      ];
    };
  };

  xdg = {
    configFile = {
      "glide/glide.ts".source = config.lib.meta.createSymlink "home/common/glide/config/glide.ts";
      # Chrome rules live in the repo (live-editable via <leader>c); only the
      # palette is generated, so a scheme switch restyles without touching them.
      "glide/press.css".source = config.lib.meta.createSymlink "home/common/glide/config/press.css";
      "glide/press-palette.css".source = pressTokens;
    };

    dataFile."glide-pages".source = pages;
  };
}
