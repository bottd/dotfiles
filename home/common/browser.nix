{ lib, pkgs, ... }: {
  home.sessionVariables = {
    BROWSER = "glide";
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
      (_: "glide.desktop");
  };

  home.activation.defaultBrowser = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "trampolineApps" ] ''
      ${pkgs.duti}/bin/duti -s app.glide-browser.glide http
      ${pkgs.duti}/bin/duti -s app.glide-browser.glide https
      ${pkgs.duti}/bin/duti -s app.glide-browser.glide public.html all
      ${pkgs.duti}/bin/duti -s app.glide-browser.glide public.xhtml all
    ''
  );
}
