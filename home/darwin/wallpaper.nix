{ pkgs, ... }:
let
  wallpaperDay = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/tokyo-night/wallpapers/main/light/city_light.png";
    hash = "sha256-0000000000000000000000000000000000000000000=";
  };
  wallpaperNight = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/tokyo-night/wallpapers/main/storm/city_storm.png";
    hash = "sha256-0000000000000000000000000000000000000000000=";
  };
in
{
  home.packages = [ pkgs.desktoppr ];

  home.file = {
    ".config/wallpapers/day.png".source = wallpaperDay;
    ".config/wallpapers/night.png".source = wallpaperNight;

    ".local/bin/set-wallpaper" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh
        WALLPAPER_DIR="$HOME/.config/wallpapers"
        MODE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
        if [[ "$MODE" == "Dark" ]]; then
            ${pkgs.desktoppr}/bin/desktoppr "$WALLPAPER_DIR/night.png"
        else
            ${pkgs.desktoppr}/bin/desktoppr "$WALLPAPER_DIR/day.png"
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
