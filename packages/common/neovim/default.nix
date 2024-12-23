{pkgs, config, lib, inputs, ...}: {
  home.file = {
    ".config/nvim/after" = {
      source = ./after;
      recursive = true;
    };

    ".config/nvim/lua" = {
      source = ./lua;
      recursive = true;
    };

    ".config/nvim/dict.txt" = {
      source = ./dict.txt;
    };

    ".config/nvim/init.lua" = {
      source = ./init.lua;
    };

    ".config/nvim/rocks.toml" = {
      source = ./rocks.toml;
    };
  };

  programs.neovim.enable = true;
}
