{ pkgs
, inputs
, ...
}:
let
  catppuccin-latte-css = pkgs.fetchurl {
    url = "https://catppuccin.github.io/discord/dist/catppuccin-latte.theme.css";
    sha256 = "0d3g69lvdqmv4v02ypnkgl1rrxrab9h2yakp6awd70fv8jmxpqvz";
  };
  catppuccin-mocha-css = pkgs.fetchurl {
    url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
    sha256 = "18c99y3pf6y93iq7fa31v7hhlwmzbwvzhar1wm8y0fj5c7164wa9";
  };
in
{
  home.packages = with pkgs; [
    vesktop
    flashprint
    geary
    godot
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
    nyxt
    obs-studio
    vlc
  ];

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
  };

  xdg.configFile."vesktop/settings/settings.json".text = builtins.toJSON {
    autostart = true;
    minimizeToTray = false;
    discordBranch = "stable";
    arRPC = true;
    vencordDir = "$HOME/.config/vesktop/vencordDist";
  };

  xdg.configFile."vesktop/settings/quickCss.css".text = ''
    /* Apply Catppuccin Mocha (dark) theme by default */
    ${builtins.readFile catppuccin-mocha-css}
    
    /* Override with Catppuccin Latte (light) theme when system prefers light mode */
    @media (prefers-color-scheme: light) {
      ${builtins.readFile catppuccin-latte-css}
    }
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
