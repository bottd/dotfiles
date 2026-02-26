{ pkgs, ... }:
let
  wallpaperDay = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/Cloudsday.jpg";
    hash = "sha256-+EkcQlbWPGud6dvRNqB+yRe8T1UsNAenwrLgFLy3G2A=";
  };
  wallpaperNight = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/Cloudsnight.jpg";
    hash = "sha256-jBv9iKBVQbgd1cmv+ubiJQH7qydRJZTShmwzEiJJcDA=";
  };
in
{
  home.packages = [ pkgs.desktoppr ];

  home.file = {
    ".config/wallpapers/Cloudsday.jpg".source = wallpaperDay;
    ".config/wallpapers/Cloudsnight.jpg".source = wallpaperNight;

    ".local/bin/set-wallpaper" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh
        WALLPAPER_DIR="$HOME/.config/wallpapers"
        MODE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
        if [[ "$MODE" == "Dark" ]]; then
            ${pkgs.desktoppr}/bin/desktoppr "$WALLPAPER_DIR/Cloudsnight.jpg"
        else
            ${pkgs.desktoppr}/bin/desktoppr "$WALLPAPER_DIR/Cloudsday.jpg"
        fi
      '';
    };
  };

  launchd.agents.wallpaper-switcher = {
    enable = true;
    config = {
      Label = "com.user.wallpaper-switcher";
      ProgramArguments = [ "/bin/zsh" "-c" "$HOME/.local/bin/set-wallpaper" ];
      WatchPaths = [ "/Users/drakebott/Library/Preferences/.GlobalPreferences.plist" ];
      RunAtLoad = true;
    };
  };
}
