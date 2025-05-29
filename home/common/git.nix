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
    github-desktop
    git-filter-repo
    lazygit
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/x-github-desktop-dev-auth" = [ "github-desktop.desktop" ];
      "x-scheme-handler/x-github-desktop-auth" = [ "github-desktop.desktop" ];
      "x-scheme-handler/x-github-client-auth" = [ "github-desktop.desktop" ];
    };
  };
}
