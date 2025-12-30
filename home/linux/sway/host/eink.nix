{ pkgs, ... }:
let
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
      fonts = {
        names = [ "MonoLisa Nerd Font" ];
        size = 12.0;
      };

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

      keybindings =
        let
          mod = "Mod4";
        in
        {
          "${mod}+n" = "exec ghostty -e nvim";
          "${mod}+b" = "exec foliate";
        };

      startup = [
        { command = "ghostty -e nvim"; }
      ];

      output = {
        "*" = {
          bg = "${colors.bg} solid_color";
        };
      };
    };

    extraConfig = ''
      seat * hide_cursor 3000
      for_window [class=".*"] opacity 1
      for_window [app_id=".*"] opacity 1
    '';
  };

  programs.fuzzel = {
    settings = {
      main = {
        font = "MonoLisa Nerd Font:size=14";
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

  home.packages = with pkgs; [
    foliate
    zathura
  ];

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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
    };
  };
}
