{pkgs, ...}: {
  home.packages = with pkgs; [
    # Utility for filtering git repo history, useful for cleaning accidentally committed secrets
    pkgs.git-filter-repo
  ];
}
