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
    filezilla
    flashprint
    helvum
    krita
    losslesscut-bin
    mpv
    obs-studio
    openscad
    tresorit-fhs
    vesktop
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
