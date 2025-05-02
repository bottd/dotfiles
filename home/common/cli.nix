{
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    android-tools
    gcc
    gh
    git
    # Utility for filtering git repo history, useful for cleaning accidentally committed secrets
    git-filter-repo
    gnumake

    himalaya

    neofetch
    readline
    typst

    unzip
    wget
  ];

  # home.packages = with pkgs-unstable; [
  # claude-code
  # jujutsu
  # ];
}
