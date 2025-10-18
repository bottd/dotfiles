{ pkgs, config, ... }: {
  home = {
    file = {
      ".config/nvim/after" = {
        source = ./after;
        recursive = true;
      };

      ".config/nvim/fnl" = {
        source = config.lib.meta.createSymlink "home/common/neovim/fnl";
      };

      ".config/nvim/dict.txt" = {
        source = ./dict.txt;
      };

      ".config/nvim/.nvim-thyme.fnl" = {
        source = ./nvim-thyme.fnl;
      };

      ".config/nvim/init.lua" = {
        text =
          #lua
          ''
            local rocks_config = {
              rocks_path = vim.fn.stdpath("data") .. "/rocks",
              luarocks_binary = "${pkgs.lua51Packages.luarocks}/bin/luarocks",
              luarocks_config = {
                arch = "${
                  if pkgs.stdenv.hostPlatform.isDarwin
                    then "macosx-aarch64"
                  else "linux-x86_64"
                }"
              }
            }

            vim.g.rocks_nvim = rocks_config

            local luarocks_path = {
              vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
              vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
            }
            package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

            local luarocks_cpath = {
              vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
              vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
            }
            package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")

            if not vim.uv.fs_stat(rocks_config.rocks_path) then
              vim.system({
                rocks_config.luarocks_binary,
                "install",
                "--tree",
                rocks_config.rocks_path,
                "--server='https://nvim-neorocks.github.io/rocks-binaries/'",
                "--lua-version=5.1",
                "rocks.nvim",
              }):wait()
            end
            vim.opt.runtimepath:append(vim.fs.joinpath(rocks_config.rocks_path, "lib", "luarocks", "rocks-5.1", "rocks.nvim", "*"))
              table.insert(package.loaders, function(...)
              return require("thyme").loader(...)
            end)
            local thyme_cache_prefix = vim.fn.stdpath("cache") .. "/thyme/compiled"
            vim.opt.rtp:prepend(thyme_cache_prefix)

            require("thyme").setup()
            require("general_config")
          '';
      };

      ".config/nvim/rocks.toml" = {
        source = config.lib.meta.createSymlink "home/common/neovim/rocks.toml";
      };
    };

    packages = with pkgs; [
      ripgrep
      tree-sitter
      # grammar/spellcheck lsp
      harper

      # for startup dashboard
      fortune
      cowsay

      # GUI
      neovide

      # images
      imagemagick
      luajitPackages.magick
      ghostscript
      mermaid-cli
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
    };
  };

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    extraLuaPackages = ps: [ ps.fennel ];
  };
}
