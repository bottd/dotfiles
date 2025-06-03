{ inputs
, lib
, pkgs
, ...
}: {
  home.file = {
    ".config/ghostty/config" = {
      text =
        #ghostty
        ''
          ${
            if pkgs.stdenv.isLinux
            then "command = nu"
            else ""
          }

          desktop-notifications = false

          font-family = MonoLisa Variable
          font-family-bold = MonoLisa Variable Regular Bold
          font-family-italic = MonoLisa Variable Italic Italic
          font-family-bold-italic = MonoLisa Variable Italic Bold Italic

          macos-non-native-fullscreen = true

          mouse-hide-while-typing = true

          quit-after-last-window-closed = true

          shell-integration = detect

          theme = dark:catppuccin-mocha,light:catppuccin-latte

          background-opacity = 0.8
          background-blur-radius = 20
        '';
    };
  };

  home.packages = lib.optionals pkgs.stdenv.isLinux [
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
