{ config, lib, pkgs, hostName, features, ... }:
let
  isPocket = hostName == "pocket";

  # Waybar's right-side modules; laptop-only extras added on pocket.
  rightModules =
    [ "tray" "pulseaudio" "network" ]
    ++ lib.optionals isPocket [ "custom/cellular" "backlight" "battery" ]
    ++ [ "clock" ];
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
  ];

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

      # niri keeps each column at its opened width; niri-even-widths (scripts/)
      # rebalances landscape workspaces to 1 / min(n,3) so a lone window is full
      # width, two split ½, three+ hold at ⅓ and scroll. Skipped on headless.
      spawn-at-startup = lib.optionals features.gui [{ argv = [ "niri-even-widths" ]; }];

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

        # Workspaces
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        # move-column-to-workspace isn't in config.lib.niri.actions as a bare
        # builder (only the -down/-up variants are), so use the path form.
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
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
        "Mod+Space".action = switch-focus-between-floating-and-tiling;
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

        "Mod+Shift+E".action = quit;
        "Mod+Shift+P".action = power-off-monitors;
      };
    };

    # ---- Waybar: KDE-style bottom panel -------------------------------
    waybar = {
      enable = features.gui;
      systemd.enable = true;
      settings.main = {
        layer = "top";
        position = "bottom";
        height = 32;
        spacing = 6;
        modules-left = [ "niri/workspaces" ];
        modules-center = [ "niri/window" ];
        modules-right = rightModules;

        "niri/workspaces".format = "{index}";
        "niri/window" = {
          format = "{}";
          max-length = 80;
        };
        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "<tt><big>{:%Y %B}</big>\n{calendar}</tt>";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 muted";
          format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
          on-click = "pavucontrol";
        };
        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀 {ifname}";
          format-disconnected = "󰤭 off";
          tooltip-format = "{ifname}: {ipaddr}";
          on-click = "nm-connection-editor";
        };
        # Cellular (pocket): waybar's `network` module has no modem support, so
        # poll ModemManager directly. `-m any` grabs the first modem.
        "custom/cellular" = {
          exec = pkgs.writeShellScript "waybar-cellular" ''
            kv=$(${pkgs.modemmanager}/bin/mmcli -m any --output-keyvalue 2>/dev/null) \
              || { echo '{"text":""}'; exit 0; }
            get() { printf '%s\n' "$kv" | ${pkgs.gnused}/bin/sed -n "s/^$1 *: //p"; }
            state=$(get modem.generic.state)
            if [ "$state" != connected ]; then
              printf '{"text":"󰣲","tooltip":"cellular: %s"}\n' "''${state:-off}"; exit 0
            fi
            printf '{"text":"󰄋 %s%%","tooltip":"%s · %s"}\n' \
              "$(get modem.generic.signal-quality.value)" \
              "$(get modem.3gpp.operator-name)" \
              "$(get modem.generic.access-technologies.value)"
          '';
          return-type = "json";
          interval = 30;
          on-click = "nm-connection-editor";
        };
        tray = {
          icon-size = 16;
          spacing = 8;
        };
        # Only ever rendered on pocket — `battery` is in rightModules under
        # isPocket. {time} is blank when full/plugged, hence format-full.
        battery = {
          states = { warning = 30; critical = 15; };
          format = "{icon} {capacity}% ({time})";
          format-charging = "󰂄 {capacity}% ({time})";
          format-full = "󰁹 {capacity}%";
          format-time = "{H}h{M}m";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };
        backlight = {
          format = "󰃟 {percent}%";
          on-scroll-up = "brightnessctl set 5%+";
          on-scroll-down = "brightnessctl set 5%-";
        };
      };
      # No `style`: stylix.targets.waybar owns the CSS (colors + font), themed
      # to the active base16 scheme. Module layout/config stays ours above.
    };

    fuzzel.enable = true;
  };

  services.mako.enable = features.gui;
  # Network management is the waybar `network` module (on-click
  # nm-connection-editor) + blueman for bluetooth; no separate nm-applet tray.
  # The polkit agent comes from niri-flake (niri-flake-polkit / polkit-kde).
}
