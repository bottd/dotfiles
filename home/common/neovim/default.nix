{
  pkgs,
  config,
  nixpkgs-unstable,
  theme,
  ...
}:
let
  # nvim sources ftdetect/ftplugin as *.{vim,lua} only, so the fnl sources get
  # compiled here rather than at runtime. A syntax error fails the switch.
  afterCompiled = pkgs.callPackage ./compile-after.nix { };

  spork = pkgs.callPackage ../../../packages/janet/spork.nix { };
  janet-lsp = pkgs.callPackage ./janet/janet-lsp.nix { inherit spork; };

in
{
  imports = [ ./nixd.nix ];

  home = {
    file = {
      ".config/nvim/after" = {
        source = afterCompiled;
        recursive = true;
      };

      ".config/nvim/lsp" = {
        source = ./lsp;
        recursive = true;
      };

      ".config/nvim/fnl" = {
        source = config.lib.meta.createSymlink "home/common/neovim/fnl";
      };

      ".config/nvim/.nvim-thyme.fnl" = {
        source = ./.nvim-thyme.fnl;
      };

      # Out-of-store so `:Lux add`/`:Lux remove` edit the tracked file.
      ".config/nvim/lux.toml" = {
        source = config.lib.meta.createSymlink "home/common/neovim/lux.toml";
      };

      # luxstrap downloads a prebuilt lux.so that needs libz.so.1, which
      # NixOS doesn't provide. With one already here it skips the download.
      ".local/share/nvim/lux.so".source =
        "${nixpkgs-unstable.luajitPackages.lux-lua}/share/lux-lua/jit/lux.so";
    };

    packages = with pkgs; [
      ripgrep
      tree-sitter

      # for startup dashboard
      cowsay
      fortune

      # janet
      janet
      spork
      janet-lsp
    ];

    sessionVariables = {
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    };
  };

  stylix.targets.neovim.enable = false;

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    package = nixpkgs-unstable.neovim-unwrapped;
    initLua =
      #lua
      ''
        -- Loads lux.so (nix-provided, symlinked into stdpath("data")) and installs lux.nvim on first
        -- run. Once installed, lux.nvim is loaded synchronously right here.
        vim.pack.add({ "https://github.com/lumen-oss/luxstrap.nvim" }, { load = true })

        vim.g.stylix_theme = "${theme.scheme}"
        vim.g.stylix_appearance = "${theme.appearance}"

        local ok, thyme = pcall(require, "thyme")
        if ok then
        table.insert(package.loaders, function(...)
        return thyme.loader(...)
        end)
        local thyme_cache_prefix = vim.fn.stdpath("cache") .. "/thyme/compiled"
        vim.opt.rtp:prepend(thyme_cache_prefix)
        -- thyme reads .nvim-thyme.fnl via vim.secure.read, which resolves the
        -- symlink to a /nix/store path that changes on every edit. Trust it
        -- here so the prompt never fires; the file is nix-managed, not
        -- project-local.
        vim.secure.trust({
        action = "allow",
        path = vim.fn.stdpath("config") .. "/.nvim-thyme.fnl",
        })
        thyme.setup()
        require("general_config")
        require("plugin_setup")
        else
        vim.notify("nvim-thyme not installed yet - watch :messages, then :Lux sync and restart", vim.log.levels.WARN)
        end
      '';
  };
}
