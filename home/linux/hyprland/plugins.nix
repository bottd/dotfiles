{ pkgs
, ...
}: {
  # Cool Hyprland plugins to enhance your setup
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      # Visual effects
      hyprfocus # Flash windows when changing focus
      borders-plus-plus # Additional customizable borders

      # Window management
      hyprspace # macOS/KDE-like workspace overview (Super+Tab)
      hyprsplit # Better split controls

      # Quality of life
      hyprgrass # Touch gestures support
      hyprexpo # Expose-like window overview
    ];

    settings = {
      # Hyprfocus - flash on focus change
      "plugin:hyprfocus" = {
        enabled = "yes";
        animate_floating = "yes";
        animate_workspacechange = "yes";
        focus_animation = "flash";
        # Customization
        flash_opacity = "0.7";
        in_speed = "0.5";
        out_speed = "3";
      };

      # Borders++ - double borders for better visibility
      "plugin:borders-plus-plus" = {
        add_borders = "2";
        "col.border_1" = "rgba($mauveAlpha99)";
        "col.border_2" = "rgba($pinkAlpha99)";
        border_size_1 = "10";
        border_size_2 = "5";
      };

      # Hyprspace bindings
      bind = [
        "SUPER, Tab, overview:toggle"
      ];

      # Enhanced animations
      animation = [
        "windows, 1, 3, default, popin 80%"
        "windowsMove, 1, 3, default, slide"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 3, default, slidefade 20%"
        "specialWorkspace, 1, 3, default, slidefadevert 20%"
      ];
    };
  };
}

