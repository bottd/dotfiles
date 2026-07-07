{ config, inputs, ... }: {
  imports = [ inputs.glide.homeModules.default ];

  programs.glide-browser = {
    enable = true;

    # Force Kagi as the only search engine. Baked into policies.json via
    # wrapFirefox; verify at about:policies. SearchEngines.Remove needs an
    # ESR-style build to honor it — if the built-ins linger, glide ignored it.
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

  home.file.".config/glide" = {
    source = config.lib.meta.createSymlink "home/common/glide/config";
  };
}
