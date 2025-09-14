{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Rust
    cargo-binstall
    (rustup.overrideAttrs (_oldAttrs: { doCheck = false; }))

    # JavaScript/Node
    nodejs
    nodePackages_latest.svelte-language-server
    nodePackages_latest.typescript-language-server
    nodePackages_latest.prettier
    prettierd
    stylelint-lsp
    tailwindcss-language-server
    vscode-langservers-extracted

    # Lua
    lua5_1
    lua51Packages.luarocks
    lua-language-server
    lux-cli
    stylua

    # Nix
    nil

    # Clojure
    clojure
    clojure-lsp
    leiningen
    cljfmt
    clj-kondo
    babashka
    jet

    # Janet
    janet
    jpm

    # Fennel
    fennel
    fnlfmt

    # Common Lisp
    sbcl

    # TOML
    taplo
  ];

  # NPM configuration
  home.file.".npmrc".text = ''
    prefix = ~/.npm-packages
  '';
}
