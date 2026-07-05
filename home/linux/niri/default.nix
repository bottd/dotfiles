{ config, lib, pkgs, hostName, ... }:
let
  c = config.lib.stylix.colors; # base16 hex, no leading '#'
  font = config.stylix.fonts.monospace.name;
  isPocket = hostName == "pocket";

  # Per-host `output` blocks (a plain KDL string), spliced into config.kdl.
  niriOutputs = import ./host/${hostName}.nix;

  # Auto-stacks windows vertically on portrait outputs (niri has no native
  # vertical layout — issue #1071). Watches niri IPC, consumes new windows into
  # the column. Tune VERTICAL_STACK_N in the script for windows-per-column.
  niriStackToN = pkgs.fetchFromGitHub {
    owner = "FarokhRaad";
    repo = "niri-stack-to-n";
    rev = "a8a76e35d6cd3149c7a47417d75779d533942c8a";
    hash = "sha256-2Hur7XFq6V/ZD/ONLlllFQYTW/QotSE9FFFjjxtLMXg=";
  };

  # Only desktop has a portrait monitor; skip the helper on the pocket.
  stackSpawn = lib.optionalString (!isPocket) ''
    // Auto-stack windows vertically on portrait monitors (no native niri
    // option — issue #1071). The helper detects portrait outputs itself.
    spawn-at-startup "${pkgs.python3}/bin/python3" "${niriStackToN}/niri_stack_to_n.py"'';

  # Right-hand modules: laptop-only extras (backlight, battery) folded in.
  rightModules =
    [ "tray" "pulseaudio" "network" ]
    ++ lib.optionals isPocket [ "backlight" "battery" ]
    ++ [ "clock" ];
in
{
  # `programs.niri` here comes from niri-flake's NixOS module, which injects its
  # home-manager module automatically (via home-manager.sharedModules) — so we
  # must NOT import homeModules.niri again. It validates the KDL at build time.

  home.packages = with pkgs; [
    swaylock
    brightnessctl
    playerctl
    pavucontrol
    networkmanagerapplet # nm-connection-editor for the bar's on-click
    xwayland-satellite # X11 apps under niri
  ];

  programs = {
    # ---- niri compositor config ---------------------------------------
    # Raw KDL (validated at build time by niri-flake). We keep hand-written
    # KDL rather than the typed `settings` DSL — it's one readable file.
    niri.config = ''
      // Managed by home-manager (home/linux/niri). Edit the Nix file, not this.
      // niri reloads this file live on save — no restart needed.

      input {
          keyboard {
              xkb { layout "us"; }
          }
          touchpad {
              tap
              natural-scroll
          }
          focus-follows-mouse max-scroll-amount="0%"
          warp-mouse-to-focus
      }

      // ---- Monitors (per-host) ----
      ${niriOutputs}

      layout {
          gaps 8
          center-focused-column "never"
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          default-column-width { proportion 0.5; }
          focus-ring {
              width 2
              active-color "#${c.base0D}"
              inactive-color "#${c.base02}"
          }
          border { off; }
      }

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot-%Y-%m-%d-%H-%M-%S.png"

      hotkey-overlay { skip-at-startup; }

      // X11 apps: niri manages xwayland-satellite itself (finds it on PATH,
      // spawns on demand, and sets DISPLAY dynamically).
      xwayland-satellite { }

      ${stackSpawn}

      window-rule {
          geometry-corner-radius 6
          clip-to-geometry true
      }

      binds {
          Mod+Shift+Slash { show-hotkey-overlay; }

          Mod+Return { spawn "ghostty"; }
          Mod+D      { spawn "fuzzel"; }
          Mod+Q      { close-window; }
          Mod+Alt+L  { spawn "swaylock"; }

          // Focus (vim keys, matching the old sway setup)
          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+J { focus-window-down; }
          Mod+K { focus-window-up; }

          // Move
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
          Mod+Shift+J { move-window-down; }
          Mod+Shift+K { move-window-up; }

          // Monitors (desktop is dual-head)
          Mod+Ctrl+H { focus-monitor-left; }
          Mod+Ctrl+L { focus-monitor-right; }
          Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

          Mod+Home { focus-column-first; }
          Mod+End  { focus-column-last; }

          // Workspaces
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }
          Mod+U { focus-workspace-down; }
          Mod+I { focus-workspace-up; }

          // Sizing / layout
          Mod+F       { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+C       { center-column; }
          Mod+R       { switch-preset-column-width; }
          Mod+Minus   { set-column-width "-10%"; }
          Mod+Equal   { set-column-width "+10%"; }
          Mod+Comma   { consume-window-into-column; }
          Mod+Period  { expel-window-from-column; }
          Mod+Space       { switch-focus-between-floating-and-tiling; }
          Mod+Shift+Space { toggle-window-floating; }

          // Screenshots (niri built-in)
          Print           { screenshot; }
          Mod+Print       { screenshot-screen; }
          Mod+Shift+Print { screenshot-window; }

          // Media / volume / brightness
          XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"; }
          XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
          XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
          XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
          XF86AudioPlay  allow-when-locked=true { spawn "playerctl" "play-pause"; }
          XF86AudioNext  allow-when-locked=true { spawn "playerctl" "next"; }
          XF86AudioPrev  allow-when-locked=true { spawn "playerctl" "previous"; }

          Mod+Shift+E { quit; }
          Mod+Shift+P { power-off-monitors; }
      }
    '';

    # ---- Waybar: KDE-style bottom panel -------------------------------
    waybar = {
      enable = true;
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
        tray = {
          icon-size = 16;
          spacing = 8;
        };
        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };
        backlight = {
          format = "󰃟 {percent}%";
          on-scroll-up = "brightnessctl set 5%+";
          on-scroll-down = "brightnessctl set 5%-";
        };
      };
      style = ''
        * {
          font-family: "${font}";
          font-size: 13px;
          min-height: 0;
        }
        window#waybar {
          background: #${c.base00};
          color: #${c.base05};
        }
        #workspaces button {
          padding: 0 8px;
          color: #${c.base04};
          background: transparent;
        }
        #workspaces button.active {
          color: #${c.base00};
          background: #${c.base0D};
          border-radius: 4px;
        }
        #workspaces button.urgent {
          color: #${c.base00};
          background: #${c.base08};
          border-radius: 4px;
        }
        #window { color: #${c.base04}; }
        #clock, #pulseaudio, #network, #battery, #backlight, #tray {
          padding: 0 10px;
        }
        #battery.charging { color: #${c.base0B}; }
        #battery.critical:not(.charging) { color: #${c.base08}; }
        #network.disconnected { color: #${c.base08}; }
      '';
    };

    fuzzel.enable = true;
  };
  # We own the waybar CSS; keep stylix from also styling it.
  stylix.targets.waybar.enable = false;

  services.mako.enable = true;
  # Network management is the waybar `network` module (on-click
  # nm-connection-editor) + blueman for bluetooth; no separate nm-applet tray.
  # The polkit agent comes from niri-flake (niri-flake-polkit / polkit-kde).
}
