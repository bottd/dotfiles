{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      chromium
      filezilla
      flashprint
      crosspipe
      nautilus
      kdePackages.kdenlive
      glaxnimate
      inkscape
      krita
      libreoffice
      losslesscut-bin
      mupdf
      openscad
      # not in nixpkgs and upstream ships no flake, so it's packaged locally
      (pkgs.callPackage ./icy-draw { })
      pablodraw
      signal-desktop
    ];
  };

  programs.sioyek.enable = true;

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
  };

  xdg = {
    configFile."mimeapps.list".force = true;

    mimeApps.defaultApplications = {
      "application/pdf" = "sioyek.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
      "application/msword" = "writer.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
      "application/vnd.ms-excel" = "calc.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
      "text/csv" = "calc.desktop";
    };

    mimeApps.enable = true;
  };
}
