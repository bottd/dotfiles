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
    target = "link";
  };

  home.file.".config/nvim/init.lua" = {
    source = ./init.lua;
    target = "link";
  };

  home.file.".config/nvim/rocks.toml" = {
    source = ./rocks.toml;
    target = "link";
  };


  programs.neovim.enable = true;
}
