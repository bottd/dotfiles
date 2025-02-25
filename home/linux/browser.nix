{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    nyxt
  ];
}
