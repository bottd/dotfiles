{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ../neovim;
    target = "link";
  };
  programs.neovim.enable = true;
}
