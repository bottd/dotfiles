{ pkgs, ... }:
# Heavy production apps: large or built locally, so they live on the desktop
# only and the smaller machines rebuild quickly.
{
  imports = [
    ../../home/desktop/emacs.nix
    ./obs.nix
  ];

  home.packages = with pkgs; [
    flashprint
    kdePackages.kdenlive
    glaxnimate
    inkscape
    krita
    libreoffice
    losslesscut-bin
    openscad
    # not in nixpkgs and upstream ships no flake, so it's packaged locally
    (callPackage ./icy-draw { })
    pablodraw
  ];

  xdg.mimeApps.defaultApplications = {
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
    "application/msword" = "writer.desktop";
    "application/vnd.oasis.opendocument.text" = "writer.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
    "application/vnd.ms-excel" = "calc.desktop";
    "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
    "text/csv" = "calc.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
    "application/vnd.ms-powerpoint" = "impress.desktop";
    "application/vnd.oasis.opendocument.presentation" = "impress.desktop";
  };
}
