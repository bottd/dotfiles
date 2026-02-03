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
        source = ./.nvim-thyme.fnl;
      };

      ".config/nvim/init.lua" = {
        text =
          #lua
          ''
            	  do
                -- Specifies where to install/use rocks.nvim
                local install_location = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "rocks")

                -- Set up configuration options related to rocks.nvim (recommended to leave as default)
                local rocks_config = {
                    rocks_path = vim.fs.normalize(install_location),
                    luarocks_binary = "${pkgs.lua51Packages.luarocks}/bin/luarocks",
                }

                vim.g.rocks_nvim = rocks_config

                -- Configure the package path (so that plugin code can be found)
                local luarocks_path = {
                    vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
                    vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
                }
                package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

                -- Configure the C path (so that e.g. tree-sitter parsers can be found)
                local luarocks_cpath = {
                    vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
                    vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
                }
                package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")

                -- Add rocks.nvim to the runtimepath
                vim.opt.runtimepath:append(vim.fs.joinpath(rocks_config.rocks_path, "lib", "luarocks", "rocks-5.1", "rocks.nvim", "*"))

                -- If rocks.nvim is not installed then install it!
                if not pcall(require, "rocks") then
                    vim.system({
                        rocks_config.luarocks_binary,
                        "install",
                        "--tree",
                        rocks_config.rocks_path,
                        "--server=https://lumen-oss.github.io/rocks-binaries/",
                        "--lua-version=5.1",
                        "rocks.nvim",
                    }):wait()
                end
            end
            	    local ok, thyme = pcall(require, "thyme")
                        if ok then
                          table.insert(package.loaders, function(...)
                            return thyme.loader(...)
                          end)
                          local thyme_cache_prefix = vim.fn.stdpath("cache") .. "/thyme/compiled"
                          vim.opt.rtp:prepend(thyme_cache_prefix)
                          thyme.setup()
                          require("general_config")
                        else
                          vim.notify("nvim-thyme not installed yet - run :Rocks sync", vim.log.levels.WARN)
                        end
          '';
      };

      ".config/nvim/rocks.toml" = {
        source = config.lib.meta.createSymlink "home/common/neovim/rocks.toml";
      };
    };

    packages = with pkgs; [
      ripgrep
      tree-sitter
      lua5_1
      harper

      # rust
      cargo
      rust-analyzer

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
      LUA_INCDIR = "${pkgs.lua5_1}/include";
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    };
  };

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    extraLuaPackages = ps: [ ps.fennel ];
  };
}
