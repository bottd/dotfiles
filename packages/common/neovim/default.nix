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
      source = config.lib.meta.createSymlink(./dict.txt);
    };

    ".config/nvim/init.lua" = {
      source = config.lib.meta.createSymlink(./init.lua);
    };

    ".config/nvim/rocks.toml" = {
      source = config.lib.meta.createSymlink(./rocks.toml);
    };
  };

  programs.neovim.enable = true;
}
