{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # Clojure
      babashka
      clj-kondo
      cljfmt
      clojure
      clojure-lsp
      jet
      leiningen

      # Common Lisp
      sbcl

      # Fennel
      fnlfmt
      luaPackages.fennel

      # Janet
      janet
      jpm

      # JavaScript/Node
      nodejs
      prettier
      svelte-language-server
      typescript-language-server
      prettierd
      stylelint-lsp
      tailwindcss-language-server
      vscode-langservers-extracted

      # Lua
      lua-language-server
      lua5_1
      lua51Packages.luarocks
      stylua

      # Nix
      nil

      # Python
      python3

      # TOML
      taplo
    ];

    sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-packages";
    sessionPath = [ "$HOME/.npm-packages/bin" ];
  };
}
