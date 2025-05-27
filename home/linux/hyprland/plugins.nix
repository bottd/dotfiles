{ pkgs
, ...
}: {
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      borders-plus-plus
      hyprsplit
      hyprgrass
    ];

    settings = {
      "plugin:borders-plus-plus" = {
        add_borders = "2";
        "col.border_1" = "rgba($mauveAlpha99)";
        "col.border_2" = "rgba($pinkAlpha99)";
        border_size_1 = "10";
        border_size_2 = "5";
      };

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

