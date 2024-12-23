{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ../neovim;
    target = "link";
    recursive = true;
  };
  programs.neovim.enable = true;
}
