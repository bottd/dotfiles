{ pkgs, ... }: {
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
        "workbench.iconTheme" = "catppuccin-mocha";
        "workbench.productIconTheme" = "catppuccin-mocha";
        "editor.fontFamily" = "'MonoLisa Variable'";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;
        "editor.smoothScrolling" = true;
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = true;
      };
    };
  };
}
