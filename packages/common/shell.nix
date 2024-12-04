{pkgs, ...}: {
  programs.nushell.enable = true;
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };
}
