{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    android-tools
    gcc
    gnumake

    himalaya

    neofetch
    readline
    typst

    unzip
    wget
    zellij
  ];
}
