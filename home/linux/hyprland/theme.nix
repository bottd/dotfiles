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
  };

  home.sessionVariables = {
    # If cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";

    # hint Electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
  };

  # software needed for hyprland
  # https://wiki.hyprland.org/Useful-Utilities/Must-have/
  home.packages = with pkgs; [
    networkmanagerapplet
    catppuccin-cursors
    # bar
    # TODO: try eww for custom bar
    # simple
    # pkgs.waybar
    # TODO: try removing and see if still works
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))

    # notifications
    pkgs.dunst
    libnotify

    # Manage password/auth request popups
    hyprpolkitagent

    # wallpaper
    swww

    # Control sound devices
    pavucontrol

    # launcher
    rofi-wayland

    hyprshot

    kdePackages.ark
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kio-admin
    kdePackages.spectacle

    catppuccin-gtk
    # gnome-themes-extra
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
      exec-once = waybar
      exec-once = nm-applet --indicator
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
        gaps_in = 0;
        gaps_out = 0;
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
    };
  };
}
