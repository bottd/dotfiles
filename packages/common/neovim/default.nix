{pkgs, ...}: {
  home.file.".config/nvim/after" = {
    source = ./after;
    recursive = true;
  };

  home.file.".config/nvim/lua" = {
    source = ./lua;
    recursive = true;
  };

  home.file.".config/nvim/dict.txt" = {
    source = ./dict.txt;
  };

  home.file.".config/nvim/init.lua" = {
    source = ./init.lua;
  };

  home.file.".config/nvim/rocks.toml" = {
    source = ./rocks.toml;
  };

  programs.neovim.enable = true;
}
