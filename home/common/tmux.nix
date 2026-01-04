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

      # Fix colors
      set-option -ga terminal-overrides ",xterm-256color:Tc"

      # Enable tmux focus events
      set -g focus-events on

      # Decrease escape time (redundant with escapeTime but kept for consistency)
      set -s escape-time 0

      # --- Zellij-style keybindings ---
      # Pane mode (Ctrl+p)
      bind -n C-p select-pane -t :.+
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R
      bind -n C-n split-window -v -c '#{pane_current_path}'
      bind -n C-w split-window -h -c '#{pane_current_path}'
      bind -n C-q kill-pane

      # Tab mode (Ctrl+t) - using Alt+number for direct tab access
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9
      bind -n M-Left previous-window
      bind -n M-Right next-window
      bind -n M-n new-window -c '#{pane_current_path}'
      bind -n M-x kill-window

      # Resize mode (Ctrl+o with Alt+arrows)
      bind -n M-h resize-pane -L 5
      bind -n M-j resize-pane -D 5
      bind -n M-k resize-pane -U 5
      bind -n M-l resize-pane -R 5
      bind -n M-= select-layout -E

      # Session mode (Ctrl+g)
      bind -n C-g choose-session
      bind -n C-d detach-client
      bind -n C-s choose-session
      bind -n C-n new-session -c '#{pane_current_path}'

      # Scroll mode (Ctrl+s)
      bind -n C-s copy-mode
      bind -n T copy-mode

      # Pane resizing with Shift+arrows (traditional tmux)
      bind -n S-Left resize-pane -L 2
      bind -n S-Right resize-pane -R 2
      bind -n S-Down resize-pane -D 1
      bind -n S-Up resize-pane -U 2
    '';
  };

  home.packages = lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    wl-clipboard
  ]);
}
