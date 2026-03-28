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

  programs.difftastic = {
    enable = true;
  };

  home.packages = with pkgs; [
    gh
    git-filter-repo
    lazygit
  ];

}
