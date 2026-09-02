{ config, pkgs, ... }:
let
  inherit (config.lib.stylix) colors;

  # Equibop derives the splash's --fg-semi-trans from splashColor by string
  # surgery -- `replace("rgb(", "rgba(").replace(")", ", 0.2)")` -- so a hex
  # value matches neither call and lands fully opaque on the splash border and
  # progress fill. Emit the rgb() form it expects.
  toRgb = name: "rgb(${colors."${name}-rgb-r"}, ${colors."${name}-rgb-g"}, ${colors."${name}-rgb-b"})";
in
{
  home.packages = [ pkgs.equibop ];

  xdg = {
    configFile = {
      # Generated rather than symlinked out of store: the splash colours have to
      # follow stylix, so the -dark/-light variants of a host can't share one
      # checked-in file. Equibop's own writes to this path fail soft (it logs
      # "Failed to save settings" and carries on), and window state lives in a
      # separate state.json that stays mutable. The cost is that the first-launch
      # wizard's answers don't persist -- it writes discordBranch, minimizeToTray
      # and arRPC back here -- so all three are pinned below.
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

      "equibop/settings/quickCss.css".text =
        config.stylix.targets.vencord.themeBody
        + builtins.readFile ./tokens.css;
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
