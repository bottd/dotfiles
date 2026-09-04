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
    fd
    ffmpeg
    gcc
    gnumake
    jq
    notmuch
    readline
    typst
    unzip
    wget
  ];
}
