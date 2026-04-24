{ pkgs, lib, nixpkgs-unstable, ... }:
{
  home.packages = lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    wl-clipboard
  ]);

  programs.zellij = {
    enable = true;
    package = nixpkgs-unstable.zellij;

    settings = {
      theme = "default";
      default_shell = "zsh";
      mouse_mode = true;
      rounded_corners = true;
      show_startup_tips = false;
      show_release_notes = false;
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
}
