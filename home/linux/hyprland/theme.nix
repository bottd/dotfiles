{
  config,
  pkgs,
  inputs,
  ...
}: {
  # requried for default Hyprland config
  programs.kitty.enable = true;

  home.sessionVariables = {
    # If cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";

    # hint Electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
  };

  # software needed for hyprland
  # https://wiki.hyprland.org/Useful-Utilities/Must-have/
  home.packages = with pkgs; [
    catppuccin-cursors
    # bar
    # TODO: try eww for custom bar
    # simple
    # pkgs.waybar
    # TODO: try removing and see if still works
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))

    # notifications
    pkgs.dunst
    libnotify

    # Manage password/auth request popups
    hyprpolkitagent

    # wallpaper
    swww

    # complex but custom, want to try out espeically with the lisp syntax
    # Look into: end an nc that is built for eww
    # https://github.com/lucalabs-de/end
    # pkgs.eww

    # launcher
    rofi-wayland
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = ["--all"];
    };
    plugins = [
    ];

    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    # Added to end of .config file
    extraConfig = ''
      exec-once = waybar
    '';
    settings = {
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
    };
  };
}
