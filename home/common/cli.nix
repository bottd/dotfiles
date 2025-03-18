{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    gh
    git
    gnumake

    neofetch

    unzip
    wget
  ];
}
