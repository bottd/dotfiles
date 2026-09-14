{ config, inputs, pkgs, nixpkgs-unstable, ... }:
let
  pages = pkgs.callPackage ./pages {
    stylixPalette = config.lib.stylix.colors;
  };
in
{
  imports = [ inputs.glide.homeModules.default ];

  programs.glide-browser = {
    enable = true;

    package = nixpkgs-unstable.wrapFirefox
      (inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.glide-browser-bin-unwrapped.override {
        inherit (config.programs.glide-browser) policies;
      })
      { pname = "glide-browser-bin"; };

    policies.SearchEngines = {
      Default = "Kagi";
      Remove = [ "Google" "Bing" "DuckDuckGo" "Amazon.com" "eBay" "Wikipedia (en)" "Perplexity" ];
      Add = [{
        Name = "Kagi";
        URLTemplate = "https://kagi.com/search?q={searchTerms}";
        Method = "GET";
        IconURL = "https://kagi.com/favicon.ico";
        SuggestURLTemplate = "https://kagi.com/api/autosuggest?q={searchTerms}";
        Alias = "kagi";
      }];
    };
  };

  xdg = {
    configFile."glide/glide.ts".source =
      config.lib.meta.createSymlink "home/common/glide/config/glide.ts";

    dataFile."glide-pages".source = pages;
  };
}
