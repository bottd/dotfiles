# Minimal neovim stub — enough to be the default editor. Build your config
# on top of this (or swap in your own).
{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [ ripgrep tree-sitter ];
}
