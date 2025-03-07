{
  config,
  pkgs,
  ...
}: {
  # requried for default Hyprland config
  programs.kitty.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
  };
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind =
      [
        "$mod, F, exec, firefox"
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
  # hint Electron apps to use Wayland
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # software needed for hyprland
  # https://wiki.hyprland.org/Useful-Utilities/Must-have/
  home.packages = with pkgs; [
    # notification daemon
    swaynotificationcenter
  ];
}
