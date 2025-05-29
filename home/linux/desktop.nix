{ inputs
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    vesktop
    flashprint
    geary
    thunderbird
    nyxt
    obs-studio
    vlc
    firefox
    # TODO: figure out why with-fhs does not create a launchable like regular claude-desktop
    # inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

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
}
