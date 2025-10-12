{ pkgs, lib, ... }:
{
  home.packages = lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    wl-clipboard
  ]);

  programs.zellij = {
    enable = true;

    settings = {
      default_shell = "zsh";
      mouse_mode = true;
      rounded_corners = true;
      show_startup_tips = false;
      show_release_notes = false;
      theme = "catppuccin-mocha";
      copy_command = if pkgs.stdenv.isLinux then "wl-copy" else "pbcopy";
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
