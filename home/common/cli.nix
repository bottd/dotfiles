{ pkgs, ... }: {
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    bat.enable = true;
  };

  home.packages = with pkgs; [
    fd
    gcc
    gnumake
    jq
    unzip
    wget
  ];
}
