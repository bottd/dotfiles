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
      losslesscut-bin
      mupdf
      openscad
      # not in nixpkgs and upstream ships no flake, so it's packaged locally
      (pkgs.callPackage ./icy-draw { })
      pablodraw
      sioyek
      signal-desktop
    ];
  };

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
  };

  xdg = {
    configFile."mimeapps.list".force = true;

    mimeApps.defaultApplications = {
      "application/pdf" = "sioyek.desktop";
    };

    mimeApps.enable = true;
  };
}
