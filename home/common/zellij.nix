{ pkgs, lib, nixpkgs-unstable, ... }:
let
  # zellij splits copy_command via shell-words, so route through a wrapper
  # script that picks wl-copy or xclip based on whether a Wayland socket
  # is present at runtime (awesome/quote is X11, sway/niri is Wayland).
  linuxCopy = pkgs.writeShellScript "zellij-copy" ''
    if [ -n "$WAYLAND_DISPLAY" ]; then
      exec ${pkgs.wl-clipboard}/bin/wl-copy
    else
      exec ${pkgs.xclip}/bin/xclip -selection clipboard -in
    fi
  '';
in
{
  home.packages = lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    wl-clipboard
    xclip
  ]);

  programs.zellij = {
    enable = true;
    package = nixpkgs-unstable.zellij;

    settings = {
      theme = "default";
      default_shell = if pkgs.stdenv.isLinux then "${pkgs.zsh}/bin/zsh" else "zsh";
      mouse_mode = true;
      rounded_corners = false;
      show_startup_tips = false;
      show_release_notes = false;
      copy_command = if pkgs.stdenv.isLinux then "${linuxCopy}" else "pbcopy";
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
