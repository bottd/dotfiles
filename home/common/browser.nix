{ lib, pkgs, ... }: {
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
    defaultApplications = lib.genAttrs [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
      "x-scheme-handler/ftp"
      "x-scheme-handler/chrome"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
    ]
      (_: "firefox.desktop");
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "accessibility.force_disabled" = 1;
        "dom.webgpu.enabled" = true;
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

}
