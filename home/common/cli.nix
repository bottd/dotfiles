{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    gh
    git
    # Utility for filtering git repo history, useful for cleaning accidentally committed secrets
    git-filter-repo
<<<<<<< HEAD:home/common/cli.nix
    gh
    jujutsu
=======
>>>>>>> d8fab94 (Update):packages/common/cli.nix

    gnumake

    unzip
    wget
  ];
}
