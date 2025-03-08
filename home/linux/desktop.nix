{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    geary
    nyxt
    obs-studio
    vlc
  ];
}
