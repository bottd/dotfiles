{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    nyxt
    obs-studio
    vlc
  ];
}
