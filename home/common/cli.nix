{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    claude-code
    gcc
    gh
    git
    # Utility for filtering git repo history, useful for cleaning accidentally committed secrets
    git-filter-repo
    gnumake

    himalaya
    jujutsu

    neofetch
    readline
    typst

    unzip
    wget
  ];
}
