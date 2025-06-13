{ pkgs
, ...
}: {
  home.file = {
    ".config/hypr/mocha.conf" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/hyprland/refs/tags/v1.3/themes/mocha.conf";
        sha256 = "sha256-SxVNvZZjfuPA2yB9xA0EHHEnE9eIQJAFVBIUuDiSIxQ=";
      };
    };
    ".config/hypr/latte.conf" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/hyprland/refs/tags/v1.3/themes/latte.conf";
        sha256 = "sha256-xYhmqYTHF+nlJVIlNDY4Fyd6moEv6Z8YISTKmpX/p6k=";
      };
    };
    ".config/wallpapers" = {
      source = ../../../assets/wallpapers;
      recursive = true;
    };
  };

  home.sessionVariables = {
    # Wayland support for Chromium-based applications
    NIXOS_OZONE_WL = "1";
  };

  # software needed for hyprland
  # https://wiki.hyprland.org/Useful-Utilities/Must-have/
  home.packages = with pkgs; [
    networkmanagerapplet

    dunst
    libnotify
    hyprpolkitagent
    swww
    pavucontrol
    wlsunset
    rofi-wayland

    hyprshot

    kdePackages.ark
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kio-admin

    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];


  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    plugins = [
      pkgs.hyprlandPlugins.hyprbars
    ];

    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    extraConfig =
      ''
        # Source current theme (will be managed by darkman)
              source = ~/.config/hypr/current-theme.conf

              general {
                border_size = 0
                  gaps_in = 8
                  gaps_out = 16
                  col.active_border = rgba($mauveAlpha99)
                  col.inactive_border = rgba($baseAlpha99)
              }

              exec-once = eww daemon && eww open-many bar_1 bar_2
              exec-once = nm-applet --indicator
              exec-once = swww-daemon
              exec-once = swww img ~/.config/wallpapers/lighthouse.png
              exec-once = wlsunset -l 41.9 -L -87.6

              # Essential environment variables for portal functionality
              env = XDG_CURRENT_DESKTOP,Hyprland
              env = XDG_SESSION_DESKTOP,Hyprland

              # Auto-start applications in overlay workspace
              exec-once = [workspace special:overlay silent] vesktop
              exec-once = [workspace special:overlay silent] ghostty
              exec-once = [workspace special:journal silent] neovide -- -c 'Neorg journal today'

        # Hyprbars configuration with Catppuccin colors
              plugin {
                hyprbars {
                  bar_height = 20
                    col.text = $text
                    bar_text_size = 12
                    bar_text_font = Sans
                    bar_text_align = center
                    bar_part_of_window = true
                    bar_precedence_over_border = true
                    bar_buttons_alignment = right
                    bar_padding = 16
                    bar_button_padding = 4

        # Window buttons
                    hyprbars-button = $red, 12, , hyprctl dispatch killactive
                    hyprbars-button = $yellow, 12, , hyprctl dispatch fullscreen 1
                    hyprbars-button = $green, 12, , hyprctl dispatch togglefloating
                }

              }

              windowrulev2 = plugin:hyprbars:bar_color rgba($mauveAlpha99),focus:1
              windowrulev2 = plugin:hyprbars:title_color $crust,focus:1
              windowrulev2 = plugin:hyprbars:bar_color rgba($crustAlpha99),focus:0
      '';
    settings = {
      decoration = {
        blur = {
          popups = true;
        };
      };

      input = {
        follow_mouse = 2;
        # Mouse raw input
        sensitivity = 0;
      };

      general = {
        allow_tearing = true;
      };

      gestures = {
        # defaults to 3 finger swipe
        workspace_swipe = true;
        workspace_swipe_touch = true;
      };
      misc = {
        vfr = false;
        vrr = 1;
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
        force_default_wallpaper = false;
      };

      windowrule = [
        "immediate, class:^(gamescope)$"
        "fullscreen, class:^(gamescope)$"
        "noanim, class:^(gamescope)$"
      ];
    };
  };
}
