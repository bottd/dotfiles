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
}
