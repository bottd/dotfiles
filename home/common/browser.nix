{ lib, pkgs, ... }: {
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
    defaultApplications =
      let
        firefox = "firefox.desktop";
      in
      {
        "text/html" = firefox;
        "application/xhtml+xml" = firefox;
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
        "x-scheme-handler/about" = firefox;
        "x-scheme-handler/unknown" = firefox;
        "x-scheme-handler/ftp" = firefox;
        "x-scheme-handler/chrome" = firefox;
        "application/x-extension-htm" = firefox;
        "application/x-extension-html" = firefox;
        "application/x-extension-shtml" = firefox;
        "application/x-extension-xhtml" = firefox;
        "application/x-extension-xht" = firefox;
      };
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
