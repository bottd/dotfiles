{ pkgs
, ...
}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "accessibility.force_disabled" = 1;
      };
      search = {
        default = "Kagi";
        force = true;
        engines = {
          "Kagi" = {
            urls = [
              {
                template = "https://kagi.com/search?q={searchTerms}";
              }
              {
                template = "https://kagi.com/api/autosuggest?q={searchTerms}";
                type = "application/x-suggestions+json";
              }
            ];
            definedAliases = [ "@k" ];
          };
        };
      };
    };
  };

  home.packages = with pkgs; [
    inkscape
  ];
}
