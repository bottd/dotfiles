{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    gh
    git
    # Utility for filtering git repo history, useful for cleaning accidentally committed secrets
    git-filter-repo
    gh
    jujutsu

    gnumake

    unzip
    wget
  ];
}
