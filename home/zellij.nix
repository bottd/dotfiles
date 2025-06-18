{ ... }:
{
  programs.zellij = {
    enable = true;

    settings = {
      default_shell = "nu";
      mouse_mode = true; # defaults to true
      rounded_corners = true;
      show_startup_tips = false;
      show_release_notes = false;
      theme = "catppuccin-mocha";
      # TODO:
      # - Auto dark/light mode
      # - Rounded tab borders instead of arrow

      # keybinds_clear_defaults = true;
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
    zellij = ''zellij --theme catppuccin-''${CATPPUCCIN_FLAVOR:-mocha}'';
  };
}
