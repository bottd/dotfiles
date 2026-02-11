{ pkgs
, inputs
, system
, ...
}:
let
  tresorit-fhs = inputs.nix-tresorit.packages.${system}.default;
  catppuccin-latte-css = pkgs.fetchurl {
    url = "https://catppuccin.github.io/discord/dist/catppuccin-latte.theme.css";
    sha256 = "sha256-Wq2SLe/RuSkJEryn8eA8MqNvbgsE1ILkI1yqfTzVjuY=";
  };
  catppuccin-mocha-css = pkgs.fetchurl {
    url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
    sha256 = "sha256-KVv9vfqI+WADn3w4yE1eNsmtm7PQq9ugKiSL3EOLheI=";
  };
in
{
  home.packages = with pkgs; [
    vesktop
    flashprint
    filezilla
    krita
    losslesscut-bin
    obs-studio
    helvum
    openscad
    mpv
    tresorit-fhs
  ];

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
  };

  xdg = {
    configFile = {
      "vesktop/settings/settings.json".text = builtins.toJSON {
        autostart = true;
        minimizeToTray = false;
        discordBranch = "stable";
        arRPC = true;
        vencordDir = "$HOME/.config/vesktop/vencordDist";
      };

      "vesktop/settings/quickCss.css".text = ''
        /* Apply Catppuccin Mocha (dark) theme by default */
        ${builtins.readFile catppuccin-mocha-css}

        /* Override with Catppuccin Latte (light) theme when system prefers light mode */
        @media (prefers-color-scheme: light) {
          ${builtins.readFile catppuccin-latte-css}
        }
      '';

      "mimeapps.list".force = true;
    };

    desktopEntries.discord = {
      name = "Discord";
      genericName = "Internet Messenger";
      exec = "vesktop %U";
      icon = "discord";
      categories = [ "Network" "InstantMessaging" "Chat" ];
      type = "Application";
    };

    mimeApps.enable = true;
  };
}
