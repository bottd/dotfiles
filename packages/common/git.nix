{pkgs, ...}: {
  home.packages = with pkgs; [
    # Utility for filtering git repo history, useful for cleaning accidentally committed secrets
    git-filter-repo
  ];
}
