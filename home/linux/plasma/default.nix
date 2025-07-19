{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.yakuake
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.okular
    kdePackages.gwenview
    kdePackages.filelight
    kdePackages.kcalc
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursor.theme = "breeze_cursors";
      iconTheme = "breeze-dark";
    };

    panels = [
      {
        location = "bottom";
        height = 44;
      }
    ];

    shortcuts = {
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
      "kwin"."Switch to Desktop 5" = "Meta+5";
      "kwin"."Switch to Desktop 6" = "Meta+6";
      "kwin"."Switch to Desktop 7" = "Meta+7";
      "kwin"."Switch to Desktop 8" = "Meta+8";
      "kwin"."Switch to Desktop 9" = "Meta+9";
      "kwin"."Window Close" = "Meta+Q";
      "kwin"."Window Maximize" = "Meta+M";
      "kwin"."Window Minimize" = "Meta+N";
      "kwin"."Window to Desktop 1" = "Meta+Shift+1";
      "kwin"."Window to Desktop 2" = "Meta+Shift+2";
      "kwin"."Window to Desktop 3" = "Meta+Shift+3";
      "kwin"."Window to Desktop 4" = "Meta+Shift+4";
      "kwin"."Window to Desktop 5" = "Meta+Shift+5";
      "kwin"."Window to Desktop 6" = "Meta+Shift+6";
      "kwin"."Window to Desktop 7" = "Meta+Shift+7";
      "kwin"."Window to Desktop 8" = "Meta+Shift+8";
      "kwin"."Window to Desktop 9" = "Meta+Shift+9";
      "org.kde.dolphin.desktop"."_launch" = "Meta+E";
      "org.kde.konsole.desktop"."_launch" = "Meta+T";
      "org.kde.krunner.desktop"."_launch" = "Meta+Space";
    };

    configFile = {
      "kdeglobals"."KDE"."SingleClick" = false;
    };
  };
}
