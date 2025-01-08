{pkgs, ...}: {
  home.packages = with pkgs; [
    eslint

    nodejs
    nodePackages_latest.graphql-language-service-cli
    nodePackages_latest.svelte-language-server
    nodePackages_latest.typescript-language-server
    nodePackages_latest.prettier
    # prettier daemon
    fsouza-prettierd

    stylelint-lsp
    tailwindcss-language-server
  ];
}
