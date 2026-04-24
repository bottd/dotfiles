{ pkgs, nixpkgs-unstable, ... }: {
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    bat.enable = true;
  };

  home.packages = (with pkgs; [
    android-tools
    devcontainer
    fd
    gcc
    gnumake
    himalaya
    jq
    readline
    typst
    unzip
    wget
  ]) ++ [ nixpkgs-unstable.zellij ];
}
