{ ...
}: {
  home.file = {
    ".config/eww/scripts/auto-theme.nu" = {
      source = ./scripts/auto-theme.nu;
      executable = true;
    };

    ".config/eww/scripts/check-theme.nu" = {
      source = ./scripts/check-theme.nu;
      executable = true;
    };

    ".config/eww/scripts/toggle-theme.nu" = {
      source = ./scripts/toggle-theme.nu;
      executable = true;
    };

    ".config/eww/eww.yuck" = {
      text = ''
        (defwidget theme-switcher []
          (box :orientation "v"
               :space-evenly false
               (label :text "Theme: {{current_theme}}")
               (button :onclick "~/.config/eww/scripts/toggle-theme.nu"
                       :class "theme-button"
                       "Switch Theme")))

        (defpoll current_theme :interval "30s"
          "~/.config/eww/scripts/check-theme.nu")

        (defpoll auto_theme :interval "300s"
          "~/.config/eww/scripts/auto-theme.nu")

        (defwindow theme-control
          :monitor 0
          :geometry (geometry :x "10px"
                            :y "10px"
                            :width "150px"
                            :height "80px"
                            :anchor "top right")
          :stacking "bg"
          :exclusive false
          (theme-switcher))

        (defwindow theme-daemon
          :monitor 0
          :geometry (geometry :x "0px"
                            :y "0px"
                            :width "1px"
                            :height "1px"
                            :anchor "top right")
          :stacking "bg"
          :exclusive false
          :visible false
          (box :class "theme-daemon"
               :orientation "v"))
      '';
    };

    ".config/eww/eww.scss" = {
      text = ''
        * {
          all: unset;
          font-family: "JetBrainsMono Nerd Font";
        }

        .theme-button {
          background-color: #313244;
          color: #cdd6f4;
          padding: 10px;
          border-radius: 10px;
          margin: 5px;
        }

        .theme-button:hover {
          background-color: #45475a;
        }
      '';
    };
  };
}
