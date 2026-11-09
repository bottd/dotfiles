{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      chromium
      filezilla
      crosspipe
      nautilus
      mupdf
      signal-desktop
    ];
  };

  programs.sioyek.enable = true;

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "sioyek.desktop";
  };
}
