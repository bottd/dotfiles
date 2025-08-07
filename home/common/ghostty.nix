{ lib, pkgs, inputs, system, ... }: {
  home.file = {
    ".config/ghostty/config" = {
      text = ''
        desktop-notifications = false

        font-family = MonoLisa Variable
        font-family-bold = MonoLisa Variable Regular Bold
        font-family-italic = MonoLisa Variable Italic Italic
        font-family-bold-italic = MonoLisa Variable Italic Bold Italic

        macos-non-native-fullscreen = true

        mouse-hide-while-typing = true

        quit-after-last-window-closed = true

        shell-integration = none

        theme = dark:catppuccin-mocha,light:catppuccin-latte

        background-opacity = 0.8
        background-blur-radius = 20

        gtk-titlebar = true
      '';
    };
  };

  home.packages = lib.optionals pkgs.stdenv.isLinux [
    inputs.ghostty.packages.${system}.default
  ];
}
