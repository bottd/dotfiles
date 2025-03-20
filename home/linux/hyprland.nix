{
  config,
  pkgs,
  ...
}: {
  # requried for default Hyprland config
  programs.kitty.enable = true;

  # hint Electron apps to use Wayland
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # software needed for hyprland
  # https://wiki.hyprland.org/Useful-Utilities/Must-have/
  home.packages = with pkgs; [
    # Manage password/auth request popups
    hyprpolkitagent
    # Notification manager
    swaynotificationcenter
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = ["--all"];
    };
    plugins = [];
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    # Added to end of .config file
    extraConfig = "";
    settings = {
      general = {
        borderSize = "4";
      };
      decoration = {
        blur = {
          popups = true;
        };
      };

      gestures = {
        # defaults to 3 finger swipe
        workspace_swipe = true;
        workspace_swipe_touch = true;
      };
      misc = {
        disable_hyprland_logo = true;
      };
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
  };
}
