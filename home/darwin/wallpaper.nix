{ pkgs, ... }:
let
  # Same landscape wallpaper as the niri desktop (home/linux/niri/host/desktop.nix).
  wallpaper = ../../assets/wallpapers/autumn-river.png;
in
{
  home = {
    packages = [ pkgs.desktoppr ];

    file.".config/wallpaper.png".source = wallpaper;

    activation.set-wallpaper = ''
      ${pkgs.desktoppr}/bin/desktoppr "$HOME/.config/wallpaper.png"
    '';
  };
}
