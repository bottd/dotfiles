{pkgs, config, lib, inputs, ...}: {
  home.file = {
    ".config/nvim/after" = {
      source = config.lib.meta.createSymlink("packages/common/neovim/after");
      recursive = true;
    };

    ".config/nvim/lua" = {
      source = config.lib.meta.createSymlink("packages/common/neovim/lua");
      recursive = true;
    };

    ".config/nvim/lua/plugins" = {
      source = config.lib.meta.createSymlink("packages/common/neovim/lua/plugins");
      recursive = true;
    };

    ".config/nvim/dict.txt" = {
      source = config.lib.meta.createSymlink("packages/common/neovim/dict.txt");
    };

    ".config/nvim/init.lua" = {
      source = config.lib.meta.createSymlink("packages/common/neovim/init.lua");
    };

    ".config/nvim/rocks.toml" = {
      source = config.lib.meta.createSymlink("packages/common/neovim/rocks.toml");
    };
  };

  home.packages = with pkgs; [ 
    lua5_1

    # Used for startup dashboard
    fortune
    cowsay
  ];

  programs.neovim.enable = true;
}
