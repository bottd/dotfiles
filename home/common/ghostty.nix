{
  config,
  lib,
  pkgs,
  hostName,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isLinux then pkgs.ghostty else null;
    settings = {
      command = lib.mkIf config.programs.zellij.enable "zellij";
      desktop-notifications = false;

      font-family = lib.mkForce "MonoLisa Variable";
      font-family-bold = "MonoLisa Variable Regular Bold";
      font-family-italic = "MonoLisa Variable Italic Italic";
      font-family-bold-italic = "MonoLisa Variable Italic Bold Italic";
      font-feature = "ss02";

      macos-non-native-fullscreen = true;

      mouse-hide-while-typing = true;

      quit-after-last-window-closed = true;

      shell-integration = "none";

      background-opacity = 1.0;

      # Dither Press: the cursor is the accent plate, and the grid sits inside
      # a narrow print margin instead of running to the trim.
      cursor-style = "block";
      cursor-style-blink = false;
      cursor-color = "#${
        if hostName == "eink" then config.lib.stylix.colors.base07 else config.lib.stylix.colors.base09
      }";
      cursor-text = "#${config.lib.stylix.colors.base00}";
      window-padding-x = 8;
      window-padding-y = 6;
      window-padding-balance = true;
      window-padding-color = "extend";

      gtk-titlebar = true;

      macos-titlebar-style = "native";

      keybind = "alt+enter=unbind";
    };
  };
}
