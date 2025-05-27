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
    NIXOS_OZONE_WL = "1";
  };

  # software needed for hyprland
  # https://wiki.hyprland.org/Useful-Utilities/Must-have/
  home.packages = with pkgs; [
    networkmanagerapplet
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))

    pkgs.dunst
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
    ];

    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    # Added to end of .config file
    extraConfig = ''
      # Source Catppuccin theme
      source = ~/.config/hypr/mocha.conf
      
      general {
        border_size = 8
        gaps_in = 8
        gaps_out = 16
        col.active_border = rgba($mauveAlpha99)
        col.inactive_border = rgba($baseAlpha99)
      }
      
      exec-once = waybar
      exec-once = nm-applet --indicator
      exec-once = swww-daemon
      exec-once = swww img ~/.config/wallpapers/lighthouse.png
      exec-once = wlsunset -l 41.9 -L -87.6
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
