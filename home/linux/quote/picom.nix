{ pkgs, ... }:
{
  services.picom = {
    enable = true;
    package = pkgs.picom;
    backend = "xrender";
    vSync = false;

    shadow = true;
    fade = true;
    fadeDelta = 4;

    settings = {
      # shadows on xwinwrap's root drawable smear the wallpaper layer
      shadow-exclude = [
        "class_g = 'xwinwrap'"
        "name = 'Notification'"
      ];

      detect-rounded-corners = true;
      detect-client-opacity = true;
      use-damage = true;

      inactive-opacity = 0.95;
      active-opacity = 1.0;
      frame-opacity = 1.0;
      inactive-opacity-override = false;
    };
  };
}
