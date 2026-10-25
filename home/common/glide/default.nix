{
  config,
  inputs,
  pkgs,
  nixpkgs-unstable,
  ...
}:
let
  inherit (config.lib.ditherPress) colors font sizes;
  px = n: "${toString n}px";

  # Dither Press tokens (home/common/dither-press.nix) as CSS custom
  # properties, shared by the chrome (press.css) and the new tab page.
  pressTokens = pkgs.writeText "press-palette.css" ''
    :root {
      --press-paper: ${colors.paper};
      --press-surface: ${colors.surface};
      --press-hover: ${colors.hover};
      --press-rule: ${colors.rule};
      --press-muted: ${colors.muted};
      --press-ink: ${colors.ink};
      --press-plate: ${colors.plate};
      --press-danger: ${colors.danger};
      --press-font: ${builtins.toJSON font};
      --press-font-size: ${px sizes.font};
      --press-heading-size: ${px sizes.heading};
      --press-caption-size: ${px sizes.caption};
      --press-rule-width: ${px sizes.rule};
      --press-plate-offset: ${px sizes.plateOffset};
      --press-offset: ${px sizes.pressOffset};
      --press-panel-offset: ${px sizes.panelOffset};
      --press-gap: ${px sizes.gap};
      --press-half-gap: ${px sizes.halfGap};
      --press-inset: ${px sizes.inset};
      --press-tile-size: ${px sizes.tile};
      --press-seam-height: ${px sizes.seam};
      --press-seam-cell: ${px sizes.seamCell};
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
