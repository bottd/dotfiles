# Desktop environment configuration module that uses the config system
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Get the module configuration
  cfg = moduleSystem.getModuleConfig config.sysConfig.desktop;

  # Helper to check if a feature is enabled
  isEnabled = feature: cfg.${feature} or false;
in {
  config = lib.mkIf (isEnabled "enable") (lib.mkMerge [
    # Base packages for any desktop environment
    {
      environment.systemPackages = with pkgs; [
        # Common utilities
        xdg-utils
        xdg-user-dirs
        libnotify

        # Common applications
        gnome.adwaita-icon-theme
        gnome.gnome-themes-extra
        hicolor-icon-theme

        # Fonts
        font-awesome
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
      ];

      # Basic font configuration
      fonts = {
        packages = with pkgs; [
          (nerdfonts.override {
            fonts = [
              "JetBrainsMono"
              "FiraCode"
              "Meslo"
            ];
          })
          inter
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
        ];

        fontconfig = {
          defaultFonts = {
            serif = ["Noto Serif" "Times New Roman"];
            sansSerif = ["Inter" "Noto Sans"];
            monospace = ["JetBrainsMono Nerd Font" "Fira Code"];
            emoji = ["Noto Color Emoji"];
          };
        };
      };
    }

    # Wayland-specific configuration
    (lib.mkIf (isEnabled "useWayland") {
      environment.systemPackages = with pkgs; [
        # Wayland utilities
        wl-clipboard
        grim
        slurp
        mako
        wlr-randr
        waybar
        swaylock
        swayidle
      ];

      # XDG portal for Wayland
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
      };

      # Make sure we're using Wayland for everything possible
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        XDG_SESSION_TYPE = "wayland";
      };
    })

    # X11-specific configuration
    (lib.mkIf (isEnabled "useX11") {
      # Enable the X11 windowing system
      services.xserver.enable = true;

      # Configure keyboard
      services.xserver.xkb = {
        layout = "us";
        variant = "";
        options = "caps:escape";
      };

      # Enable touchpad support
      services.xserver.libinput = {
        enable = true;
        touchpad = {
          disableWhileTyping = true;
          naturalScrolling = true;
          tapping = true;
          clickMethod = "clickfinger";
        };
      };

      # X11 packages
      environment.systemPackages = with pkgs; [
        xclip
        xsel
        arandr
        xorg.xdpyinfo
        xorg.xev
        xorg.xhost
        xorg.xinput
        xorg.xrandr
      ];
    })

    # Hyprland configuration
    (lib.mkIf (isEnabled "useHyprland") {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      environment.systemPackages = with pkgs; [
        wofi
        waybar
        dunst
        swww
        hyprpaper
      ];

      # Enable display manager for Hyprland
      services.displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
      };
    })

    # GNOME configuration
    (lib.mkIf (isEnabled "useGnome") {
      services.xserver.desktopManager.gnome.enable = true;
      services.xserver.displayManager.gdm.enable = true;

      environment.systemPackages = with pkgs; [
        gnome.gnome-tweaks
        gnome.dconf-editor
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
      ];

      # Exclude some default GNOME apps
      environment.gnome.excludePackages = with pkgs.gnome; [
        epiphany # Web browser
        totem # Video player
        geary # Email client
        cheese # Webcam tool
      ];
    })

    # KDE configuration
    (lib.mkIf (isEnabled "useKDE") {
      services.xserver.desktopManager.plasma5.enable = true;
      services.xserver.displayManager.sddm.enable = true;

      environment.systemPackages = with pkgs; [
        libsForQt5.kate
        libsForQt5.krita
        libsForQt5.konsole
        libsForQt5.plasma-browser-integration
      ];

      # KDE Connect
      programs.kdeconnect.enable = true;
    })

    # Theme configuration
    {
      # GTK theming
      environment.systemPackages = with pkgs; [
        # Theme engines
        gtk-engine-murrine
        gtk_engines

        # Theme tools
        lxappearance
        qt5ct
        libsForQt5.qtstyleplugins

        # Catppuccin themes (based on cfg.theme.name)
        catppuccin-gtk
        catppuccin-kde
        catppuccin-cursors
      ];

      # QT platform theme
      qt = {
        enable = true;
        platformTheme = "gtk2";
        style = "gtk2";
      };

      # Set environment variables for theming
      environment.sessionVariables = {
        GTK_THEME = "Catppuccin-${cfg.theme.accent}-${
          if cfg.theme.dark
          then "Dark"
          else "Light"
        }";
      };
    }
  ]);
}
