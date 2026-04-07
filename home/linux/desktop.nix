{ pkgs
, inputs
, system
, ...
}:
let
  tresorit-fhs = inputs.nix-tresorit.packages.${system}.default;
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

      # Cleared — Stylix handles theming via GTK
      "vesktop/settings/quickCss.css".text = "";

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
