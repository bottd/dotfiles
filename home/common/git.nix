{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings = {
      user.email = "bottd@users.noreply.github.com";
      push = {
        autoSetupRemote = true;
      };
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
    };
  };

  home.packages = with pkgs; [
    gh
    git-filter-repo
    lazygit
  ];

}
