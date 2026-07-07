{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings = {
      # Set these to your own name/email.
      user.name = "Mark";
      user.email = "mark@example.com";
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
