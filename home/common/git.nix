{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userEmail = "bottd@users.noreply.github.com";
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

  programs.bash.initExtra = ''
    export GITHUB_TOKEN="$(gh auth token)"
  '';

  programs.zsh.initExtra = ''
    export GITHUB_TOKEN="$(gh auth token)"
  '';
}
