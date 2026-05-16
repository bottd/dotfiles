{ pkgs, ... }:
{
  services.dunst = {
    enable = true;
    settings.global = {
      # font is set by stylix system-wide
      frame_width = 1;
      corner_radius = 2;
      offset = "12x12";
      origin = "top-right";
      notification_limit = 5;
      idle_threshold = 120;
    };
  };

  home.packages = [ pkgs.libnotify ];
}
