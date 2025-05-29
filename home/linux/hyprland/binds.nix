{ ...
}: {
  wayland.windowManager.hyprland = {
    settings = {
      "$mod" = "SUPER";

      bind =
        [
          "$mod, F, exec, zen"
          # "$mod, T, exec, ghostty"
          "$mod, S, exec, rofi -show drun -show-icons"
          "$mod, Q, killactive"
          "$mod, P, exec, hyprshot -m region"
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
