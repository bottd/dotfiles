{
  config,
  lib,
  pkgs,
  inputs,
  hostName,
  features,
  ...
}:
let
  # Empty off gaming hosts, which hides the panel's Games entry.
  aurelia = lib.optionalString features.gaming (
    lib.getExe inputs.aurelia.packages.${pkgs.stdenv.hostPlatform.system}.default
  );
  # The games script reads aurelia from AURELIA; its list adds Steam's cached
  # icons and its play reports a failed launch through mako.
  games = lib.optionals features.gaming [
    (lib.getExe' pkgs.coreutils "env")
    "AURELIA=${aurelia}"
    (lib.getExe (import ../../../scripts { inherit pkgs; }).games)
  ];

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

  qmltermwidget = pkgs.callPackage ./qmltermwidget.nix {
    inherit (config.lib.stylix) colors;
  };

  inherit (config.lib.stylix) colors;
  shaders = import ./shaders.nix { inherit lib colors; };

  # The QML modules plus the compiled print shader, so PrintEffect.qml can
  # resolve it next to itself.
  quickshellModules =
    pkgs.runCommand "quickshell-modules" { nativeBuildInputs = [ pkgs.qt6.qtshadertools ]; }
      ''
        cp -r ${./quickshell/modules} $out
        chmod -R u+w $out
        qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 \
          -o $out/press-print.frag.qsb ${pkgs.writeText "press-print.frag" shaders.qtPrint}
        # Top-level labels of the public suffix list, so the web panel can tell
        # git.drake.bot (a URL) from flake.nix (a search) the way Glide does.
        {
          echo '.pragma library'
          printf 'var tlds = new Set(['
          awk '!/^\/\// && NF { n = split($1, p, "."); print tolower(p[n]) }' \
            ${pkgs.publicsuffix-list}/share/publicsuffix/public_suffix_list.dat \
            | sort -u | sed 's/.*/"&"/' | paste -sd,
          echo ']);'
        } > $out/tlds.js
      '';

  # Media keys change the level, then ask the shell to show it.
  showLevel = kind: "qs ipc call levels ${kind}";

  scopeRun =
    args:
    [
      "${pkgs.systemd}/bin/systemd-run"
      "--user"
      "--scope"
      "--quiet"
      "--collect"
    ]
    ++ args;

  searchEngine =
    let
      engines = config.programs.glide-browser.policies.SearchEngines;
    in
    lib.findFirst (
      engine: engine.Name == engines.Default
    ) (throw "glide: default search engine ${engines.Default} is not in SearchEngines.Add") engines.Add;

  journalNvim = pkgs.writeShellScript "quickshell-journal" ''
    chalet_dir="$HOME/chalet"
    journal_dir="$chalet_dir/journal"
    mkdir -p "$journal_dir"
    cd "$chalet_dir"
    export COLORTERM=truecolor
    export TERM=xterm-256color
    # Keep a shell parent: QMLTermWidget does not emit finished on CrashExit.
    ${lib.getExe config.programs.neovim.finalPackage} \
      -c 'lua vim.api.nvim_create_user_command("JournalToday", function() vim.cmd("keepalt hide edit " .. vim.fn.fnameescape(vim.fn.expand("~/chalet/journal/") .. os.date("%Y-%m-%d") .. ".norg")) end, {})' \
      "$journal_dir/$(${pkgs.coreutils}/bin/date +%F).norg"
    exit 0
  '';

in
{
  imports = [ ./host/${hostName}.nix ];

  # `programs.niri` here comes from niri-flake's NixOS module, which injects its
  # home-manager module automatically (via home-manager.sharedModules) — so we
  # must NOT import homeModules.niri again. The same auto-wiring pulls in
  # niri-flake's stylix target (homeModules.stylix, active because stylix is a
  # NixOS module here); it owns the window border + cursor colors, so we don't
  # set focus-ring/border/cursor below.

  programs.swaylock.enable = true;

  home.packages =
    with pkgs;
    [
      brightnessctl
      playerctl
      quickshell
      xdg-terminal-exec # Terminal=true desktop entries use the configured terminal
    ]
    ++ lib.optionals features.desktopApps [
      pavucontrol
      networkmanagerapplet # nm-applet's secret agent, nm-connection-editor for the network panel
      xwayland-satellite # X11 apps; niri finds it on PATH and spawns it on demand
    ];

  xdg.configFile = {
    "quickshell/shell.qml".source = ./quickshell/shell.qml;
    "quickshell/modules".source = quickshellModules;
    "quickshell/Theme.qml" = {
      text = ''
        import QtQuick

        QtObject {
            readonly property color background: "#${config.lib.stylix.colors.base00}"
            readonly property color surface: "#${config.lib.stylix.colors.base01}"
            readonly property color surfaceHover: "#${config.lib.stylix.colors.base02}"
            readonly property color surfaceSelected: "#${config.lib.stylix.colors.base02}"
            readonly property color surfacePressed: "#${config.lib.stylix.colors.base03}"
            readonly property color border: "#${config.lib.stylix.colors.base03}"
            readonly property color textPrimary: "#${config.lib.stylix.colors.base07}"
            // base04 is base16's muted-foreground slot in both polarities. The old
            // dark branch used base06, which melange doesn't define (see
            // lib/stylixScheme.nix) — it was extrapolated off the gray ramp and
            // landed 1.07:1 against base07, so "muted" text rendered at primary
            // emphasis. base04 gives a real step down: 2.04:1 dark, 2.99:1 light.
            readonly property color textMuted: "#${config.lib.stylix.colors.base04}"
            readonly property color accent: "#${config.lib.stylix.colors.base09}"
            readonly property color textOnAccent: "#${config.lib.stylix.colors.base00}"
            readonly property color focusRing: "#${config.lib.stylix.colors.base09}"
            // Dither Press: ink keylines, one accent plate printed off-register
            // behind whatever is selected, square trims everywhere.
            readonly property color ink: "#${config.lib.stylix.colors.base07}"
            readonly property color plate: "#${config.lib.stylix.colors.base09}"
            readonly property int radius: 0
            readonly property int plateOffset: Math.max(2, Math.round(fontSize / 6))  // 2
            readonly property int ruleWidth: Math.max(2, Math.round(fontSize / 6))
            readonly property int pressOffset: Math.max(3, Math.round(fontSize / 4))
            readonly property int headingSize: Math.round(fontSize * 1.4)
            // Halftone band above the bar where its paper breaks up into the
            // wallpaper. Its height is included in the bar's exclusive zone.
            readonly property int seamHeight: Math.round(fontSize / 2)        // 6
            readonly property int seamCell: 2
            // base0B/base0A are base16's green/yellow slots. The old light branch
            // used base0D (blue) and base0F (rose), which made "connected" read
            // informational and put warning closer in hue to danger (base08) than
            // to caution — at 2.80:1 on background, under the 3:1 non-text floor.
            readonly property color statusPositive: "#${config.lib.stylix.colors.base0B}"
            readonly property color statusWarning: "#${config.lib.stylix.colors.base0A}"
            readonly property color danger: "#${config.lib.stylix.colors.base08}"
            readonly property string fontFamily: ${builtins.toJSON config.stylix.fonts.monospace.name}
            readonly property int fontSize: ${toString config.stylix.fonts.sizes.terminal}
            // Every size in the shell derives from fontSize so the eink host
            // (base 20) scales instead of overflowing a layout tuned for 12.
            // The comments give the resolved value at fontSize 12.
            readonly property int controlSize: Math.round(fontSize * 2.35)   // 28
            readonly property int barHeight: Math.round(fontSize * 2.7)      // 32
            readonly property int rowHeight: Math.round(fontSize * 2.5)      // 30
            readonly property int listRowHeight: Math.round(fontSize * 4)    // 48
            readonly property int iconSize: Math.round(fontSize * 1.5)       // 18
            readonly property int listIconSize: Math.round(fontSize * 1.85)  // 22
            readonly property int overlayGap: Math.round(fontSize * 1.33)    // 16
            readonly property int overlayEdgeMargin: Math.round(fontSize * 10) // 120
            readonly property bool animationsEnabled: ${lib.boolToString features.animations}
            readonly property string journalProgram: ${builtins.toJSON journalNvim}
            readonly property var launcherCommand: ${
              builtins.toJSON (scopeRun [
                "--"
                "${pkgs.gtk3}/bin/gtk-launch"
              ])
            }
            readonly property var browserCommand: ${
              builtins.toJSON (scopeRun [
                # Otherwise the scope is named after the command line and the
                # URL or search lands in the journal.
                "--description=Glide"
                "--"
                (lib.getExe' config.programs.glide-browser.finalPackage "glide")
                # glide.desktop passes this too; without it a cold start sets
                # app_id glide-glide.
                "--name"
                "glide"
                "--new-window"
              ])
            }
            readonly property var gamesListCommand: ${
              builtins.toJSON (games ++ lib.optional features.gaming "list")
            }
            readonly property var gameCommand: ${
              builtins.toJSON (
                lib.optionals features.gaming (
                  scopeRun [
                    "--description=Games"
                    "--"
                  ]
                  ++ games
                  ++ [ "play" ]
                )
              )
            }
            // Empty without desktop apps, which hides the network panel's editor row.
            readonly property var networkEditorCommand: ${
              builtins.toJSON (
                lib.optionals features.desktopApps (scopeRun [
                  "--description=Connection editor"
                  "--"
                  (lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor")
                ])
              )
            }
            // Glide's default engine, so the web panel and the URL bar agree.
            readonly property string searchName: ${builtins.toJSON searchEngine.Name}
            readonly property string searchUrl: ${builtins.toJSON searchEngine.URLTemplate}
            readonly property string suggestUrl: ${builtins.toJSON searchEngine.SuggestURLTemplate}
        }
      '';
    };
  };

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop panel";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      # Quickshell's hot reload keeps the modules directory's cached type list,
      # so a switch that adds a component fails with "X is not a type". A
      # changed module set restarts the service instead.
      X-Restart-Triggers = [ "${quickshellModules}" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell -c default";
      Environment = [ "QML_IMPORT_PATH=${qmltermwidget}/${pkgs.qt6.qtbase.qtQmlPrefix}" ];
      Restart = "on-failure";
      RestartSec = 2;
      TimeoutStopSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs = {
    # ---- niri compositor config (typed settings DSL) ------------------
    # niri-flake validates this at build time and generates the KDL. We use
    # `settings` (not raw `config`) because niri-flake's stylix target only
    # writes into `settings` — setting `config` would override it wholesale.
    # niri reloads on rebuild-switch; no restart needed.
    # Dither Press: the desktop is a print shop. Ink (base07) on paper
    # (base00), one spot plate (base09). Depth is plate misregistration — hard
    # offset shadows, never blur — and the one moving moment is windows
    # printing in and lifting out through the wallpaper's ordered dither.
    niri.settings = {
      animations = {
        enable = features.animations;
        window-open = {
          kind.easing = {
            duration-ms = 260;
            curve = "ease-out-cubic";
          };
          custom-shader = shaders.open;
        };
        window-close = {
          kind.easing = {
            duration-ms = 200;
            curve = "ease-out-quad";
          };
          custom-shader = shaders.close;
        };
      };
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
        # 16 leaves room for the 8px plate offset without it touching the
        # neighbouring column or the bar's halftone seam.
        gaps = lib.mkDefault 16;
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
        # focus-ring / border colors come from stylix (niri-flake stylix target)
        # with mkDefault — plain assignments win. Focus is carried twice: an ink
        # keyline and the accent plate printed off-register behind it.
        border = {
          # 4, not 2: a 2px keyline disappeared against the dithered
          # wallpaper on the 1440p panels.
          width = 4;
          active.color = "#${colors.base07}";
          inactive.color = lib.mkDefault "#${colors.base02}";
          urgent.color = "#${colors.base08}";
        };
        shadow = {
          enable = lib.mkDefault true;
          offset = {
            x = 8;
            y = 8;
          };
          softness = 0;
          spread = 0;
          color = "#${colors.base09}";
          inactive-color = "#${colors.base03}55";
        };
        insert-hint.display.color = "#${colors.base09}80";
        tab-indicator = {
          width = 4;
          gap = 4;
          corner-radius = 0;
          active.color = "#${colors.base09}";
          inactive.color = "#${colors.base03}";
          urgent.color = "#${colors.base08}";
        };
        # Empty-workspace + overview backdrop have no stylix target, so with
        # image = null they'd fall back to niri's gray — wire them by hand.
        background-color = lib.mkDefault "#${config.lib.stylix.colors.base00}";
      };

      # Overview stacks workspaces like proofs on the drying rack.
      overview = {
        backdrop-color = "#${colors.base01}";
        workspace-shadow = {
          offset = {
            x = 10;
            y = 10;
          };
          softness = 0;
          spread = 0;
          color = "#${colors.base07}30";
        };
      };

      # niri-layout (scripts/) rebalances landscape workspaces to even column
      # widths and turns portrait outputs into one vertical scrolling column.
      # Reduced desktops (e-ink) do not need these background helpers.
      spawn-at-startup = lib.optionals features.desktopApps [
        { argv = [ "niri-layout" ]; }
        {
          argv = [
            "nm-applet"
            "--indicator"
          ];
        }
      ];

      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot-%Y-%m-%d-%H-%M-%S.png";
      hotkey-overlay.skip-at-startup = true;

      # Square corners: a print has a trimmed edge, not a rounded one. Clipping
      # stays on so apps that draw their own rounded CSD get trimmed square.
      window-rules = [
        { clip-to-geometry = true; }
      ];

      binds =
        with config.lib.niri.actions;
        {
          "Mod+Shift+Slash".action = show-hotkey-overlay;

          "Mod+Return".action = spawn "ghostty";
          "Mod+D".action = spawn "qs" "ipc" "call" "launcher" "toggle";
          # eink keeps Mod+B for foliate.
          "Mod+B".action = lib.mkDefault (spawn "qs" "ipc" "call" "web" "toggle");
          "Mod+Space".action = spawn "qs" "ipc" "call" "key-overlay" "toggle";
          "Mod+G" = lib.mkIf features.gaming {
            action = spawn "qs" "ipc" "call" "games" "toggle";
          };
          # keyd calls this f13; the evdev/XKB mapping exposes it as XF86Tools.
          "XF86Tools" = {
            repeat = false;
            action = spawn "qs" "ipc" "call" "key-overlay" "toggle";
          };
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
          # Mod+Space opens the native Quickshell command overlay, so floating-focus lives on Mod+Tab.
          "Mod+Tab".action = switch-focus-between-floating-and-tiling;
          "Mod+Shift+Space".action = toggle-window-floating;

          # Screenshots (niri built-in). Not bare builders in config.lib.niri.actions;
          # use the path form (empty attrset = default props).
          "Print".action.screenshot = { };
          "Mod+Print".action.screenshot-screen = { };
          "Mod+Shift+Print".action.screenshot-window = { };

          # Media / volume / brightness
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action = spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+; ${showLevel "volume"}";
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action = spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-; ${showLevel "volume"}";
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action = spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; ${showLevel "volume"}";
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
          };
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action = spawn "sh" "-c" "brightness up; ${showLevel "brightness"}";
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action = spawn "sh" "-c" "brightness down; ${showLevel "brightness"}";
          };
          "XF86AudioPlay" = {
            allow-when-locked = true;
            action = spawn "playerctl" "play-pause";
          };
          "XF86AudioNext" = {
            allow-when-locked = true;
            action = spawn "playerctl" "next";
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            action = spawn "playerctl" "previous";
          };

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
        // builtins.listToAttrs (
          lib.concatMap (i: [
            {
              name = "Mod+${toString i}";
              value.action = focus-workspace i;
            }
            {
              name = "Mod+Shift+${toString i}";
              value.action.move-column-to-workspace = i;
            }
          ]) (lib.range 1 9)
        );
    };

  };

  services.mako = {
    enable = features.desktopApps;
    # Stylix colors the notification; these set it as a trimmed print card
    # with an ink keyline, matching the bar's popups.
    settings = {
      border-radius = 0;
      border-size = 2;
      border-color = lib.mkForce "#${colors.base07}";
      "urgency=low".border-color = lib.mkForce "#${colors.base07}";
      "urgency=normal".border-color = lib.mkForce "#${colors.base07}";
      "urgency=critical".border-color = lib.mkForce "#${colors.base08}";
      padding = "10,14";
      margin = "12";
    };
  };
  # NetworkManager and Blueman provide tray applets; Quickshell renders their
  # menus in the panel and keeps the click interaction in the tray.
  # The polkit agent comes from niri-flake (niri-flake-polkit / polkit-kde).
}
