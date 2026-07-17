{ config, lib, pkgs, hostName, features, ... }:
let
  # rfkill soft-blocks every radio via /dev/rfkill's uaccess ACL — no root needed.
  # `-o SOFT` drops the hardware-block column, which reads "unblocked" even while a
  # radio is soft-blocked and would otherwise pin this to the block branch forever.
  airplaneToggle = ''
    if LC_ALL=C rfkill -n -o SOFT | grep -q unblocked; then
      rfkill block all
    else
      rfkill unblock all
    fi
  '';

  # wlr-which-key runs each `cmd` through `sh -c`, so airplaneToggle works verbatim
  # in both the menu and the XF86RFKill/Mod+Shift+A binds.
  whichKeyConfig = (pkgs.formats.yaml { }).generate "wlr-which-key.yaml" {
    font = "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.terminal}";
    background = "#${config.lib.stylix.colors.base00}e0";
    # base07, not base05: on the light scheme base05 is only 2.6:1 on base00.
    color = "#${config.lib.stylix.colors.base07}";
    border = "#${config.lib.stylix.colors.base0D}";
    border_width = 2;
    corner_r = 10;
    separator = " → ";
    anchor = "center";
    menu = [
      { key = "a"; desc = "Airplane mode"; cmd = airplaneToggle; }
      {
        key = "p";
        desc = "Power";
        submenu = [
          { key = "s"; desc = "Sleep"; cmd = "systemctl suspend"; }
          { key = "r"; desc = "Reboot"; cmd = "systemctl reboot"; }
          { key = "o"; desc = "Off"; cmd = "systemctl poweroff"; }
          { key = "l"; desc = "Lock"; cmd = "swaylock"; }
        ];
      }
    ];
  };

in
{
  imports = [ ./host/${hostName}.nix ];

  # `programs.niri` here comes from niri-flake's NixOS module, which injects its
  # home-manager module automatically (via home-manager.sharedModules) — so we
  # must NOT import homeModules.niri again. The same auto-wiring pulls in
  # niri-flake's stylix target (homeModules.stylix, active because stylix is a
  # NixOS module here); it owns the window border + cursor colors, so we don't
  # set focus-ring/border/cursor below.

  home.packages = with pkgs; [
    swaylock
    brightnessctl
    playerctl
  ] ++ lib.optionals features.gui [
    # Desktop chrome — skipped on gui = false hosts (eink).
    pavucontrol
    networkmanagerapplet # nm-connection-editor for the bar's on-click
    xwayland-satellite # X11 apps; niri finds it on PATH and spawns it on demand
    wlr-which-key
    quickshell
  ];

  xdg.configFile = {
    "wlr-which-key/config.yaml" = lib.mkIf features.gui {
      source = whichKeyConfig;
    };
    "quickshell/shell.qml" = lib.mkIf features.gui {
      source = ./quickshell/shell.qml;
    };
    "quickshell/modules" = lib.mkIf features.gui {
      source = ./quickshell/modules;
    };
    "quickshell/Theme.qml" = lib.mkIf features.gui {
      text = ''
        import QtQuick

        QtObject {
            readonly property color base00: "#${config.lib.stylix.colors.base00}"
            readonly property color base02: "#${config.lib.stylix.colors.base02}"
            readonly property color base05: "#${config.lib.stylix.colors.base05}"
            readonly property color base0D: "#${config.lib.stylix.colors.base0D}"
            readonly property string fontFamily: ${builtins.toJSON config.stylix.fonts.monospace.name}
            readonly property int fontSize: ${toString config.stylix.fonts.sizes.terminal}
        }
      '';
    };
  };

  systemd.user.services.quickshell = lib.mkIf features.gui {
    Unit = {
      Description = "Quickshell desktop panel";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell -c default";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs = {
    # ---- niri compositor config (typed settings DSL) ------------------
    # niri-flake validates this at build time and generates the KDL. We use
    # `settings` (not raw `config`) because niri-flake's stylix target only
    # writes into `settings` — setting `config` would override it wholesale.
    # niri reloads on rebuild-switch; no restart needed.
    niri.settings = {
      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
        warp-mouse-to-focus.enable = lib.mkDefault true;
      };

      layout = {
        # mkDefault on the settings hosts actually override (see host/eink.nix),
        # so they can just assign instead of reaching for mkForce.
        gaps = lib.mkDefault 8;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
          { proportion = 1.0; }
        ];
        # Open full width — no half-empty screen with a lone window. Mod+R
        # cycles down to ⅓/½/⅔ when tiling two side by side.
        default-column-width.proportion = 1.0;
        # focus-ring / border colors come from stylix (niri-flake stylix target).
        # Empty-workspace + overview backdrop have no stylix target, so with
        # image = null they'd fall back to niri's gray — wire them by hand.
        background-color = lib.mkDefault "#${config.lib.stylix.colors.base00}";
      };

      overview.backdrop-color = "#${config.lib.stylix.colors.base01}";

      # niri-layout (scripts/) rebalances landscape workspaces to even column
      # widths and turns portrait outputs into one vertical scrolling column.
      # Skipped on headless.
      spawn-at-startup = lib.optionals features.gui [
        { argv = [ "niri-layout" ]; }
        { argv = [ "nm-applet" "--indicator" ]; }
      ];

      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot-%Y-%m-%d-%H-%M-%S.png";
      hotkey-overlay.skip-at-startup = true;

      window-rules = [{
        geometry-corner-radius =
          let r = 6.0; in { top-left = r; top-right = r; bottom-left = r; bottom-right = r; };
        clip-to-geometry = true;
      }];

      binds = with config.lib.niri.actions; {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Mod+Return".action = spawn "ghostty";
        "Mod+D".action = spawn "fuzzel";
        "Mod+Q".action = close-window;
        "Mod+Alt+L".action = spawn "swaylock";

        # Focus (vim keys)
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;

        # Move
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;

        # Monitors (desktop is dual-head)
        "Mod+Ctrl+H".action = focus-monitor-left;
        "Mod+Ctrl+L".action = focus-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-window-to-monitor-left;
        "Mod+Shift+Ctrl+L".action = move-window-to-monitor-right;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;

        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;

        # Sizing / layout
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+C".action = center-column;
        "Mod+R".action = switch-preset-column-width;
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;
        # Mod+Space is the which-key trigger, so floating-focus lives on Mod+Tab.
        "Mod+Tab".action = switch-focus-between-floating-and-tiling;
        "Mod+Shift+Space".action = toggle-window-floating;

        # Screenshots (niri built-in). Not bare builders in config.lib.niri.actions;
        # use the path form (empty attrset = default props).
        "Print".action.screenshot = { };
        "Mod+Print".action.screenshot-screen = { };
        "Mod+Shift+Print".action.screenshot-window = { };

        # Media / volume / brightness
        "XF86AudioRaiseVolume" = { allow-when-locked = true; action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"; };
        "XF86AudioLowerVolume" = { allow-when-locked = true; action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"; };
        "XF86AudioMute" = { allow-when-locked = true; action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; };
        "XF86AudioMicMute" = { allow-when-locked = true; action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; };
        "XF86MonBrightnessUp" = { allow-when-locked = true; action = spawn "brightnessctl" "set" "5%+"; };
        "XF86MonBrightnessDown" = { allow-when-locked = true; action = spawn "brightnessctl" "set" "5%-"; };
        "XF86AudioPlay" = { allow-when-locked = true; action = spawn "playerctl" "play-pause"; };
        "XF86AudioNext" = { allow-when-locked = true; action = spawn "playerctl" "next"; };
        "XF86AudioPrev" = { allow-when-locked = true; action = spawn "playerctl" "previous"; };

        # Airplane mode. Not allow-when-locked: a lock screen shouldn't expose a
        # radio kill switch that could cut off remote-locate before a thief does.
        "XF86RFKill".action = spawn "sh" "-c" airplaneToggle;
        "Mod+Shift+A".action = spawn "sh" "-c" airplaneToggle;

        "Mod+Shift+E".action = quit;
        "Mod+Shift+P".action = power-off-monitors;
      }
      # Workspaces: Mod+N focuses, Mod+Shift+N moves. move-column-to-workspace
      # isn't in config.lib.niri.actions as a bare builder (only the -down/-up
      # variants are), so use the path form.
      // builtins.listToAttrs (lib.concatMap
        (i: [
          { name = "Mod+${toString i}"; value.action = focus-workspace i; }
          { name = "Mod+Shift+${toString i}"; value.action.move-column-to-workspace = i; }
        ])
        (lib.range 1 9))
      # wlr-which-key is only installed/configured when features.gui, so the bind
      # would spawn a missing binary on eink.
      // lib.optionalAttrs features.gui {
        "Mod+Space".action = spawn "wlr-which-key";
      };
    };

    fuzzel.enable = true;
  };

  services.mako.enable = features.gui;
  # NetworkManager and Blueman provide tray applets; Quickshell renders their
  # menus in the panel and keeps the click interaction in the tray.
  # The polkit agent comes from niri-flake (niri-flake-polkit / polkit-kde).
}
