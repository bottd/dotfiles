{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # code-cursor
  ];

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        vscodevim.vim
      ];
      userSettings = {
        "window.autoDetectColorScheme" = true;
        "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
        "workbench.preferredLightColorTheme" = "Catppuccin Latte";
      };
    };
  };
}
