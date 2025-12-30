{ pkgs, ... }: {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
