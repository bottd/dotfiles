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

  blinkCmp = nixpkgs-unstable.vimPlugins.blink-cmp;
  blinkPairs = nixpkgs-unstable.vimPlugins.blink-pairs;

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

      # lux installs blink.* as bare rocks (no .git, no cargo build), so their
      # download/build helpers can't run. Take the native libs from nixpkgs,
      # whose versions must match the lux.toml pins (assert below).
      # blink.cmp: `require("blink_cmp_fuzzy")` finds $rtp/lua/*.so.
      ".config/nvim/lua/blink_cmp_fuzzy.so".source =
        assert blinkCmp.version == "1.10.2";
        "${blinkCmp}/target/release/libblink_cmp_fuzzy.so";
      # blink.pairs (via blink.lib): resolves $rtp/lib/lib<name>.so.
      ".config/nvim/lib/libblink_pairs_parser.so".source =
        assert blinkPairs.version == "0.7.1";
        "${blinkPairs}/lib/libblink_pairs_parser.so";
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
        -- lux installs into site/pack/lux/start, which nvim only adds to rtp
        -- after init.lua finishes. Load it now so require("thyme") below works.
        vim.cmd.packloadall()

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
