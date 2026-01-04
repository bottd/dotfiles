{ lib, pkgs, inputs, system, ... }: {
  # Ghostty `command` option fails tolaunch zellij on darwin
  # start zellij via zsh instead on darwin
  programs.zsh.initContent = lib.optionalString pkgs.stdenv.isDarwin ''
    if [[ -z "$ZELLIJ" && $- == *i* ]]; then
      zellij
    fi
  '';

  home.file = {
    ".config/ghostty/config" = {
      text = ''
        # ${lib.optionalString pkgs.stdenv.isLinux "command = zellij"}
        desktop-notifications = false

        font-family = MonoLisa Variable
        font-family-bold = MonoLisa Variable Regular Bold
        font-family-italic = MonoLisa Variable Italic Italic
        font-family-bold-italic = MonoLisa Variable Italic Bold Italic

        macos-non-native-fullscreen = true

        mouse-hide-while-typing = true

        quit-after-last-window-closed = true

        shell-integration = none

        theme = dark:Catppuccin Mocha,light:Catppuccin Latte

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
