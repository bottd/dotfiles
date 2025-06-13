{ ...
}: {
  wayland.windowManager.hyprland = {
    settings = {
      # Window rules for special workspaces
      windowrulev2 = [
        # Journal workspace rules
        "float, class:^(neovide-journal)$"
        "size 80% 80%, class:^(neovide-journal)$"
        "center, class:^(neovide-journal)$"
        "workspace special:journal silent, class:^(neovide-journal)$"
      ];

      # Special workspace configuration
      workspace = [
        "special:journal"
        "special:overlay"
      ];
      "$mod" = "SUPER";

      bind =
        [
          "$mod, F, exec, zen"
          "$mod, T, exec, ghostty"
          "$mod, S, exec, rofi -show drun -show-icons"
          "$mod, Q, killactive"
          "$mod, P, exec, hyprshot -m region"
          "$mod, J, togglespecialworkspace, journal"
          "$mod, Tab, togglespecialworkspace, overlay"
        ]
        ++ (
          builtins.concatLists (builtins.genList
            (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                "$mod, left, resizeactive, -5 0"
                "$mod, right, resizeactive, 5 0"
                "$mod, up, resizeactive, 0 -5"
                "$mod, down, resizeactive, 0 5"
              ]
            )
            9)
        );
    };
  };
}
