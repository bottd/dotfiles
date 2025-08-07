{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.zellij = {
    enable = true;

    settings = {
      default_shell = "nu";
      mouse_mode = true;
      rounded_corners = true;
      show_startup_tips = false;
      show_release_notes = false;
      theme = "catppuccin-mocha";
      copy_command = "wl-copy";
      copy_clipboard = "system";
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

  # home.shellAliases = {
  # zellij = ''zellij --theme catppuccin-''${CATPPUCCIN_FLAVOR:-mocha}'';
  # };
}
