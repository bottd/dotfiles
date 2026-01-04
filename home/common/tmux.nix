{ pkgs, lib, ... }: {
  programs.tmux = {
    enable = true;

    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "emacs";
    mouse = true;
    prefix = "C-a";
    terminal = "xterm-256color";

    extraConfig = ''
      # Unbind default keys
      unbind C-b
      bind-key C-a send-prefix

      # Split panes using | and -
      bind-key \ split-window -h -c '#{pane_current_path}'
      bind-key - split-window -v -c '#{pane_current_path}'
      unbind '"'
      unbind %

      # Pane resizing shortcuts
      bind -n S-Left resize-pane -L 2
      bind -n S-Right resize-pane -R 2
      bind -n S-Down resize-pane -D 1
      bind -n S-Up resize-pane -U 2

      # Fix colors
      set-option -ga terminal-overrides ",xterm-256color:Tc"

      # Enable tmux focus events
      set -g focus-events on

      # Decrease escape time (redundant with escapeTime but kept for consistency)
      set -s escape-time 0
    '';
  };

  home.packages = lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    wl-clipboard
  ]);
}
