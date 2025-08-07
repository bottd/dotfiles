{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userEmail = "bottd@users.noreply.github.com";
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  home.packages = with pkgs; [
    gh
    git-filter-repo
    lazygit
  ];

}
