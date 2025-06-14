{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    vesktop
    flashprint
    geary
    nyxt
    obs-studio
    vlc
  ];

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
  };

  xdg.configFile."vesktop/settings/settings.json".text = builtins.toJSON {
    autostart = false;
    minimizeToTray = false;
    discordBranch = "stable";
    arRPC = true;
    vencordDir = "$HOME/.config/vesktop/vencordDist";
  };

  xdg.configFile."vesktop/settings/quickCss.css".text = ''
    @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css");
  '';

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "x-scheme-handler/claude" = "claude-desktop.desktop";
    };
  };

  # Force overwrite mimeapps.list to prevent conflicts
  xdg.configFile."mimeapps.list".force = true;
}
