{ config, lib, pkgs, ... }:
let
  inherit (config.lib.stylix) colors;

  scripts = import ../../../scripts { inherit pkgs; };

  # Equibop derives splash transparency by replacing rgb() with rgba().
  toRgb = name: "rgb(${colors."${name}-rgb-r"}, ${colors."${name}-rgb-g"}, ${colors."${name}-rgb-b"})";
in
{
  home.packages = [ pkgs.equibop ];

  xdg = {
    configFile = {
      # Store-backed settings cannot persist wizard answers, so pin them here.
      # Window state is saved separately in state.json.
      "equibop/settings.json".text = builtins.toJSON {
        autostart = true;
        minimizeToTray = false;
        discordBranch = "stable";
        arRPC = false;
        splashColor = toRgb "base05";
        splashBackground = toRgb "base00";
        spellCheckLanguages = [ "en-US" "en" ];
        tray = true;
        trayColor = "";
        trayMainOverride = false;
      };

      # Build-time concatenation avoids IFD; semantic overrides follow the ramp.
      "equibop/settings/quickCss.css".source =
        pkgs.runCommand "equibop-quickcss.css"
          {
            themeBody = config.stylix.targets.vencord.themeBody;
            passAsFile = [ "themeBody" ];
          } ''
          cat "$themeBodyPath" > $out
          ${lib.getExe scripts.discord-ramp} ${colors.base00} ${config.stylix.polarity} >> $out
          cat ${./tokens.css} >> $out
        '';
    };

    desktopEntries.discord = {
      name = "Discord";
      genericName = "Internet Messenger";
      exec = "equibop %U";
      icon = "discord";
      categories = [ "Network" "InstantMessaging" "Chat" ];
      type = "Application";
    };
  };
}
