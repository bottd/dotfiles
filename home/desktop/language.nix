{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # Clojure
      babashka
      clj-kondo
      cljfmt
      clojure
      clojure-lsp

      # Fennel
      fnlfmt
      luaPackages.fennel

      # JavaScript/Node
      nodejs
      svelte-language-server
      typescript-language-server
      prettierd
      tailwindcss-language-server
      vscode-langservers-extracted

      # Lua
      lua-language-server
      lua5_1
      lua51Packages.luarocks
      stylua

      # Nix
      nixd
      nixfmt

      # Python
      python3

      # TOML
      taplo
    ];

    sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-packages";
    sessionPath = [ "$HOME/.npm-packages/bin" ];
  };
}
