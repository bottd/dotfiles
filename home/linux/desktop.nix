{pkgs, ...}: {
  home.packages = with pkgs; [
    geary
    nyxt
    obs-studio
    vlc
  ];
}
