{pkgs, ...}: {
  home.packages = with pkgs; [
    google-chrome
    geary
    vlc
    vscode
  ];
}
