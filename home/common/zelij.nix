{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";

      # Start in locked mode to prevent keybind conflicts with Neovim
      default_mode = "locked";

      keybinds = {
        "unbind \"Ctrl g\"" = true;
        "locked clear-defaults=true" = {
          # Unlock with Ctrl+a
          "bind \"Ctrl a\"" = {
            SwitchToMode = "tmux";
          };
        };

        "tmux clear-defaults=true" = {
          # Lock with Ctrl+a or Esc
          "bind \"Ctrl a\"" = {
            SwitchToMode = "locked";
          };
          "bind \"Esc\"" = {
            SwitchToMode = "locked";
          };

          # Single key shortcuts
          "bind \"t\"" = {
            NewTab = { };
            SwitchToMode = "locked";
          };
          "bind \"n\"" = {
            NewPane = { };
            SwitchToMode = "locked";
          };
          "bind \"h\"" = {
            MoveFocus = "Left";
            SwitchToMode = "locked";
          };
          "bind \"l\"" = {
            MoveFocus = "Right";
            SwitchToMode = "locked";
          };
          "bind \"j\"" = {
            MoveFocus = "Down";
            SwitchToMode = "locked";
          };
          "bind \"k\"" = {
            MoveFocus = "Up";
            SwitchToMode = "locked";
          };
          "bind \"x\"" = {
            CloseFocus = { };
            SwitchToMode = "locked";
          };
        };
      };
    };
  };

  home.shellAliases = {
    zellij = ''zellij --theme "catppuccin-$([[ "$WINDOW_APPEARANCE" == "light" ]] && echo "latte" || echo "mocha")"'';
  };
}
