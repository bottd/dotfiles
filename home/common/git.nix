{ pkgs, ... }: {
  programs.git = {
    enable = true;
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
    };
  };

  home.packages = with pkgs; [
    gh
    git-filter-repo
    lazygit
  ];
}
