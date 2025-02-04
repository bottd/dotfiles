{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    gh
    git
    # Utility for filtering git repo history, useful for cleaning accidentally committed secrets
    git-filter-repo
    gh
    himalaya
    jujutsu

    gnumake

    typst

    unzip
    wget
  ];
}
