{ pkgs, lib, hostName, ... }:
{
  imports = [
    ./host/${hostName}.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;

    config = {
      modifier = "Mod4"; # Super key
      terminal = "ghostty";

      # No title bars, simple borders
      window = {
        titlebar = false;
        border = 2;
      };

      # Simple gaps
      gaps = {
        inner = 0;
        outer = 0;
      };

      # Default to fullscreen for focused apps
      defaultWorkspace = "workspace number 1";

      # Minimal keybindings
      keybindings =
        let
          mod = "Mod4";
        in
        lib.mkOptionDefault {
          "${mod}+Return" = "exec ghostty";
          "${mod}+d" = "exec fuzzel";
          "${mod}+q" = "kill";
          "${mod}+Shift+e" = "exec swaymsg exit";

          # Focus
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          # Move
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          # Fullscreen
          "${mod}+f" = "fullscreen toggle";
        };

      bars = [ ]; # No bar by default, can be overridden per-host
    };
  };

  # Fuzzel launcher - minimal and fast
  programs.fuzzel = {
    enable = true;
  };

  home.packages = with pkgs; [
    fuzzel
  ];
}
