{ lib, pkgs, ... }: {
  # Ghostty `command` option fails to launch zellij on darwin
  # start zellij via zsh instead on darwin
  programs.zsh.initContent = lib.optionalString pkgs.stdenv.isDarwin ''
    if [[ -z "$ZELLIJ" && $- == *i* ]]; then
      zellij
    fi
  '';

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isLinux then pkgs.ghostty else null;
    settings = {
      command = lib.mkIf pkgs.stdenv.isLinux "zellij";
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

      gtk-titlebar = true;

      macos-titlebar-style = "native";

      keybind = "alt+enter=unbind";
    };
  };
}
