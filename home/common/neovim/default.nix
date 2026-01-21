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
            end

            -- If rocks.nvim is not installed then install it!
            if not pcall(require, "rocks") then
                local rocks_location = vim.fs.joinpath(vim.fn.stdpath("cache") --[[@as string]], "rocks.nvim")

                if not vim.uv.fs_stat(rocks_location) then
                    -- Pull down rocks.nvim
                    local url = "https://github.com/lumen-oss/rocks.nvim"
                    vim.fn.system({ "git", "clone", "--filter=blob:none", url, rocks_location })
                    -- Make sure the clone was successfull
                    assert(vim.v.shell_error == 0, "rocks.nvim installation failed. Try exiting and re-entering Neovim!")
                end

                -- If the clone was successful then source the bootstrapping script
                vim.cmd.source(vim.fs.joinpath(rocks_location, "bootstrap.lua"))

                vim.fn.delete(rocks_location, "rf")
            end
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
      lua5_1
      harper

      # rust
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
    };
  };

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    extraLuaPackages = ps: [ ps.fennel ];
  };
}
