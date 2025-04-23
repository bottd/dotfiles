{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    pkgs.hyprlandPlugins.hypr-dynamic-cursors
    catppuccin-cursors
  ];

  wayland.windowManager.hyprland = {
    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, F, exec, zen"
          "$mod, T, exec, ghostty"
          "$mod, S, exec, rofi -show drun -show-icons"
        ]
        ++ (
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );
    };
  };
}
