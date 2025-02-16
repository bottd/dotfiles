{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  home.file = {
    ".config/nvim/after" = {
      source = config.lib.meta.createSymlink "home/common/neovim/after";
      recursive = true;
    };

    ".config/nvim/lua" = {
      source = config.lib.meta.createSymlink "home/common/neovim/lua";
      recursive = true;
    };

    ".config/nvim/dict.txt" = {
      source = config.lib.meta.createSymlink "home/common/neovim/dict.txt";
    };

    ".config/nvim/init.lua" = {
      source = config.lib.meta.createSymlink "home/common/neovim/init.lua";
    };

    ".config/nvim/rocks.toml" = {
      source = config.lib.meta.createSymlink "home/common/neovim/rocks.toml";
    };
  };

  home.packages = with pkgs; [
    ripgrep
    tree-sitter
    # grammar/spellcheck lsp
    harper

    # Used for startup dashboard
    fortune
    cowsay
  ];

  programs.neovim.enable = true;
}
