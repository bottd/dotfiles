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
    devcontainer
    fd
    gcc
    gnumake
    himalaya
    jq
    notmuch
    readline
    typst
    unzip
    wget
  ];
}
