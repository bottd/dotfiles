{ pkgs, ... }: {
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    bat.enable = true;
  };

  home.packages = with pkgs; [
    android-tools
    gcc
    gnumake

    himalaya

    readline
    typst

    unzip
    wget
    zellij

    fd
    devcontainer
    jq
  ];
}
