_: {
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    mouse = true;
    terminal = "xterm-256color";
  };
}
