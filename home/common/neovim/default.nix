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
    ".local/share/nvim/rocks/luarocks-config.lua" = {
      enable = true;
      text =
        #lua
        ''
          lua_version = "5.1"
          rocks_trees = { {
            name = "rocks.nvim",
            root = "${config.xdg.configHome}/.local/share/nvim/rocks"
          } }

          variables = {
            LUA_INCDIR = "${pkgs.lua5_1}/include"
          }
          arch = "macosx-aarch64"
        '';
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

  programs.neovim = {
    defaultEditor = true;
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };
}
