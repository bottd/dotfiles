{pkgs, ...}: {
  programs.kitty.enable = true;
  programs.hyprland = {
    enable = true;
    uwsm = true;
    withUWSM = true;
  };
  programs.hyprlock.enable = true;
}
