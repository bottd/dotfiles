{ pkgs, ... }:
let
  # High contrast colors for e-ink
  colors = {
    bg = "#ffffff";
    fg = "#000000";
    border = "#000000";
    inactive = "#888888";
  };
in
{
  wayland.windowManager.sway = {
    config = {
      # E-ink optimized colors - high contrast black on white
      colors = {
        focused = {
          inherit (colors) border;
          background = colors.fg;
          text = colors.bg;
          indicator = colors.fg;
          childBorder = colors.border;
        };
        unfocused = {
          border = colors.inactive;
          background = colors.bg;
          text = colors.fg;
          indicator = colors.inactive;
          childBorder = colors.inactive;
        };
        focusedInactive = {
          border = colors.inactive;
          background = colors.bg;
          text = colors.fg;
          indicator = colors.inactive;
          childBorder = colors.inactive;
        };
      };

      # E-ink specific keybindings
      keybindings =
        let
          mod = "Mod4";
        in
        {
          # Quick access to writing and reading
          "${mod}+n" = "exec ghostty -e nvim";
          "${mod}+b" = "exec foliate"; # books
        };

      # Start with a writing session
      startup = [
        { command = "ghostty -e nvim"; }
      ];

      output = {
        # Force light background for e-ink
        "*" = {
          bg = "${colors.bg} solid_color";
        };
      };
    };

    extraConfig = ''
      # Disable all animations for e-ink
      # E-ink displays can't handle smooth transitions

      # Hide cursor after inactivity (less ghosting)
      seat * hide_cursor 3000

      # No transparency anywhere
      for_window [class=".*"] opacity 1
      for_window [app_id=".*"] opacity 1
    '';
  };

  # Fuzzel with e-ink colors
  programs.fuzzel = {
    settings = {
      main = {
        font = "monospace:size=14";
        lines = 10;
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 10;
      };
      colors = {
        background = "ffffffff";
        text = "000000ff";
        match = "000000ff";
        selection = "000000ff";
        selection-text = "ffffffff";
        border = "000000ff";
      };
      border = {
        width = 2;
      };
    };
  };

  # E-ink focused packages
  home.packages = with pkgs; [
    foliate # excellent ebook reader, GTK-based
    zathura # minimal PDF viewer
  ];

  # GTK theme - high contrast for e-ink
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = false;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = false;
    };
  };

  # Force light mode for apps
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
    };
  };
}
