{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  mogGrammar = inputs.tree-sitter-mog.packages.${pkgs.stdenv.hostPlatform.system}.tree-sitter-mog;
in
{
  home = {
    packages = with pkgs; [
      ghostscript
      imagemagick
      mermaid-cli
      cargo
      rust-analyzer
      temurin-bin-21
    ];
  };

  # Set plugin-specific options before the shared Fennel configuration loads.
  programs.neovim.initLua = lib.mkBefore ''
    -- parser/mog.so and queries/mog, built per platform by the tree-sitter-mog flake.
    -- Prepended so a stale rocks-installed mog.so can't shadow it.
    vim.opt.runtimepath:prepend("${mogGrammar}")

    vim.g.dotfiles_extra_lsp_servers = {
      "cssls", "eslint", "html", "svelte", "tailwindcss", "ts_ls", "clojure_lsp",
    }
    vim.g.dotfiles_snacks_image = {
      enabled = true,
      doc = { enabled = true, inline = true, float = true, max_width = 80, max_height = 40 },
    }
  '';
}
