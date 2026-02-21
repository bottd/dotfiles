{ config, pkgs, ... }:
let
  inherit (config.lib.niri) actions;
in
{
  programs.niri.settings.binds = {
    "Mod+Return".action = actions.spawn "ghostty";
    "Mod+D".action = actions.spawn "fuzzel";
    "Mod+Q".action = actions.close-window;
    "Mod+Shift+E".action = actions.quit;

    # Focus
    "Mod+H".action = actions.focus-column-left;
    "Mod+J".action = actions.focus-window-down;
    "Mod+K".action = actions.focus-window-up;
    "Mod+L".action = actions.focus-column-right;

    # Move
    "Mod+Shift+H".action = actions.move-column-left;
    "Mod+Shift+J".action = actions.move-window-down;
    "Mod+Shift+K".action = actions.move-window-up;
    "Mod+Shift+L".action = actions.move-column-right;

    # Workspaces
    "Mod+1".action = actions.focus-workspace 1;
    "Mod+2".action = actions.focus-workspace 2;
    "Mod+3".action = actions.focus-workspace 3;
    "Mod+4".action = actions.focus-workspace 4;
    "Mod+5".action = actions.focus-workspace 5;
    "Mod+6".action = actions.focus-workspace 6;
    "Mod+7".action = actions.focus-workspace 7;
    "Mod+8".action = actions.focus-workspace 8;
    "Mod+9".action = actions.focus-workspace 9;
    "Mod+Shift+1".action = actions.move-column-to-workspace 1;
    "Mod+Shift+2".action = actions.move-column-to-workspace 2;
    "Mod+Shift+3".action = actions.move-column-to-workspace 3;
    "Mod+Shift+4".action = actions.move-column-to-workspace 4;
    "Mod+Shift+5".action = actions.move-column-to-workspace 5;
    "Mod+Shift+6".action = actions.move-column-to-workspace 6;
    "Mod+Shift+7".action = actions.move-column-to-workspace 7;
    "Mod+Shift+8".action = actions.move-column-to-workspace 8;
    "Mod+Shift+9".action = actions.move-column-to-workspace 9;

    # Column management
    "Mod+F".action = actions.maximize-column;
    "Mod+Shift+F".action = actions.fullscreen-window;
    "Mod+Comma".action = actions.consume-window-into-column;
    "Mod+Period".action = actions.expel-window-from-column;
    "Mod+R".action = actions.switch-preset-column-width;
    "Mod+Minus".action = actions.set-column-width "-10%";
    "Mod+Equal".action = actions.set-column-width "+10%";

    # Screenshots
    "Print".action = actions.screenshot;
    "Ctrl+Print".action = actions.screenshot-screen;
    "Alt+Print".action = actions.screenshot-window;

    "Mod+Shift+P".action = actions.power-off-monitors;
  };

  programs.niri.settings.spawn-at-startup = [
    { command = [ "waybar" ]; }
  ];

  programs.fuzzel.enable = true;

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "bottom";
      modules-left = [ "wlr/taskbar" ];
      modules-right = [ "clock" ];
      clock.format = "{:%a %b %d  %H:%M}";
      "wlr/taskbar" = {
        on-click = "activate";
        on-click-middle = "close";
      };
    };
  };

  home.packages = with pkgs; [
    fuzzel
  ];
}
