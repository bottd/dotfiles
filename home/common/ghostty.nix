{ lib, pkgs, nixpkgs-unstable, ... }: {
  # Ghostty `command` option fails to launch zellij on darwin
  # start zellij via zsh instead on darwin
  programs.zsh.initContent = lib.optionalString pkgs.stdenv.isDarwin ''
    if [[ -z "$ZELLIJ" && $- == *i* ]]; then
      ${nixpkgs-unstable.zellij}/bin/zellij
    fi
  '';

  xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
    "ghostty/no-rounded.css".text = ''
      window, .background, .titlebar, .top-bar {
        border-radius: 0;
      }
    '';
  };

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isLinux then pkgs.ghostty else null;
    settings = {
      command = lib.mkIf pkgs.stdenv.isLinux "${nixpkgs-unstable.zellij}/bin/zellij";
      desktop-notifications = false;

      font-family = "MonoLisa Variable";
      font-family-bold = "MonoLisa Variable Regular Bold";
      font-family-italic = "MonoLisa Variable Italic Italic";
      font-family-bold-italic = "MonoLisa Variable Italic Bold Italic";
      font-feature = "ss02";

      macos-non-native-fullscreen = true;

      mouse-hide-while-typing = true;

      quit-after-last-window-closed = true;

      shell-integration = "none";

      background-opacity = 1.0;

      gtk-titlebar = lib.mkIf pkgs.stdenv.isLinux false;
      gtk-custom-css = lib.mkIf pkgs.stdenv.isLinux "no-rounded.css";

      # The default "single-instance" scope strips PATH down to systemd +
      # ghostty; "never" keeps spawned commands as direct ghostty children.
      linux-cgroup = lib.mkIf pkgs.stdenv.isLinux "never";

      macos-titlebar-style = "native";

      keybind = "alt+enter=unbind";
    };
  };
}
