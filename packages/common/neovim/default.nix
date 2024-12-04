{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./config;
    target = "link";
  };
  programs.neovim.enable = true;
}
