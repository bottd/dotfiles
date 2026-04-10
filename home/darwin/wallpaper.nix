{ pkgs, theme, ... }:
let
  wallpapers = {
    light = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/Cloudsday.jpg";
      hash = "sha256-+EkcQlbWPGud6dvRNqB+yRe8T1UsNAenwrLgFLy3G2A=";
    };
    dark = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/Cloudsnight.jpg";
      hash = "sha256-jBv9iKBVQbgd1cmv+ubiJQH7qydRJZTShmwzEiJJcDA=";
    };
  };
in
{
  home = {
    packages = [ pkgs.desktoppr ];

    file.".config/wallpaper.jpg".source = wallpapers.${theme.appearance};

    activation.set-wallpaper = ''
      ${pkgs.desktoppr}/bin/desktoppr "$HOME/.config/wallpaper.jpg"
    '';
  };
}
