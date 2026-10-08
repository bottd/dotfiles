{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      ghostscript
      imagemagick
      luajitPackages.magick
      mermaid-cli
      cargo
      rust-analyzer
      temurin-bin-21
    ];
    file = {
      ".config/nvim/rocks.toml".source = lib.mkForce (
        config.lib.meta.createSymlink "home/desktop/neovim/rocks.toml"
      );
      ".config/nvim/rocks-common.toml".source =
        config.lib.meta.createSymlink "home/common/neovim/rocks.toml";
    };
  };

  # Set plugin-specific options before Rocks loads the shared Fennel configuration.
  programs.neovim.initLua = lib.mkBefore ''
    vim.g.dotfiles_extra_lsp_servers = {
      "cssls", "eslint", "graphql", "html", "svelte", "tailwindcss", "ts_ls", "clojure_lsp",
    }
    vim.g.dotfiles_snacks_image = {
      enabled = true,
      doc = { enabled = true, inline = true, float = true, max_width = 80, max_height = 40 },
    }
  '';
}
