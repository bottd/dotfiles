{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";

      # Start in locked mode to prevent keybind conflicts with Neovim
      default_mode = "locked";

      keybinds = {
        "locked" = {
          "bind \"Ctrl a\"" = {
            SwitchToMode = "tmux";
          };
        };
        "tmux" = {
          "bind \"Ctrl a\"" = {
            SwitchToMode = "locked";
          };
          "bind \"Esc\"" = {
            SwitchToMode = "locked";
          };
        };
      };
    };
  };

  home.shellAliases = {
    # TODO: fix alias, theme arg does not exist
    # zellij = ''zellij --theme "catppuccin-$([[ "$WINDOW_APPEARANCE" == "light" ]] && echo "latte" || echo "mocha")"'';
  };
}
